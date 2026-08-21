#!/usr/bin/env python3
"""
AegisMind SRE - End-to-End Automated Verification Test
Simulates full alert workflow, RCA analysis, and remediation execution.
"""

import sys
import os
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.src.agent.ai_rca_engine import AIRootCauseEngine, AlertPayload
from app.src.agent.remediation_executor import K8sRemediationExecutor

class TestAegisMindRemediationFlow(unittest.TestCase):

    def setUp(self):
        self.engine = AIRootCauseEngine()
        self.executor = K8sRemediationExecutor(dry_run=True)

    def test_oom_killed_remediation(self):
        alert = AlertPayload(
            alertname="KubeMemoryOverbudgetOOM",
            namespace="production",
            deployment="payment-gateway",
            pod_name="payment-gateway-pod-1",
            severity="critical",
            message="Memory usage 98.2% exceeded container spec limit.",
            metrics={"memory_usage_pct": 98.2}
        )

        plan = self.engine.analyze_incident(alert)
        self.assertEqual(plan.recommended_action, "SCALE_OUT")
        self.assertGreaterEqual(plan.confidence_score, 0.90)

        result = self.executor.execute_plan(plan)
        self.assertTrue(result["success"])

    def test_crashloop_backoff_remediation(self):
        alert = AlertPayload(
            alertname="KubePodCrashLooping",
            namespace="production",
            deployment="auth-service",
            pod_name="auth-service-pod-99",
            severity="critical",
            message="CrashLoopBackOff cycle detected in pod.",
            metrics={}
        )

        plan = self.engine.analyze_incident(alert)
        self.assertEqual(plan.recommended_action, "ROLLBACK_DEPLOYMENT")
        self.assertGreaterEqual(plan.confidence_score, 0.95)

        result = self.executor.execute_plan(plan)
        self.assertTrue(result["success"])

if __name__ == "__main__":
    unittest.main()
