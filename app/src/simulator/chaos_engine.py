import requests
import argparse
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("ChaosEngine")

class AegisMindChaosSimulator:
    """
    Simulates Kubernetes workload incidents (OOMKilled, CrashLoopBackOff, CPU Throttle)
    by dispatching synthetic telemetry alerts to AegisMind Control Plane.
    """

    def __init__(self, target_url: str = "http://localhost:8000"):
        self.target_url = target_url.rstrip("/")

    def inject_fault(self, scenario: str, namespace: str = "production", deployment: str = "checkout-payment-api"):
        endpoint = f"{self.target_url}/api/v1/chaos/trigger"
        payload = {
            "scenario": scenario,
            "namespace": namespace,
            "target_deployment": deployment
        }

        logger.info(f"Injecting Fault -> Scenario: '{scenario}', Workload: '{deployment}' in '{namespace}'...")
        try:
            resp = requests.post(endpoint, json=payload, timeout=5)
            if resp.status_code == 200:
                data = resp.json()
                logger.info(f"Fault Injection SUCCESSFUL! Incident ID: {data.get('incident_id')}")
                logger.info(f"AI Recommended Action: {data.get('recommended_action')} (Confidence: {data.get('confidence')})")
            else:
                logger.error(f"Failed to inject fault (Status HTTP {resp.status_code}): {resp.text}")
        except Exception as e:
            logger.error(f"Connection error to AegisMind Control Plane: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="AegisMind SRE Chaos Injector CLI")
    parser.add_argument("--scenario", choices=["OOMKilled", "CrashLoopBackOff", "HighCPUThrottle", "ConfigFailure"], default="OOMKilled")
    parser.add_argument("--namespace", default="production")
    parser.add_argument("--deployment", default="checkout-payment-api")
    parser.add_argument("--target-url", default="http://localhost:8000")

    args = parser.parse_args()
    sim = AegisMindChaosSimulator(target_url=args.target_url)
    sim.inject_fault(scenario=args.scenario, namespace=args.namespace, deployment=args.deployment)
