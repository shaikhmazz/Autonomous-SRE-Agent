#!/usr/bin/env python3
"""
AegisMind SRE - Interactive Incident & Chaos Injector
Triggers simulated alerts against AegisMind Control Plane to test autonomous self-healing.
"""

import requests
import argparse

def main():
    parser = argparse.ArgumentParser(description="AegisMind SRE Incident Injector")
    parser.add_argument("--scenario", choices=["OOMKilled", "CrashLoopBackOff", "HighCPUThrottle", "ConfigFailure"], default="OOMKilled")
    parser.add_argument("--deployment", default="payment-gateway-service")
    parser.add_argument("--namespace", default="production")
    parser.add_argument("--url", default="http://localhost:8000")

    args = parser.parse_args()

    print("====================================================")
    print("⚡ AegisMind Chaos Injector - Dispatching Fault")
    print(f"Scenario:     {args.scenario}")
    print(f"Target App:   {args.deployment}")
    print(f"Namespace:    {args.namespace}")
    print(f"Control Plane:{args.url}")
    print("====================================================")

    endpoint = f"{args.url.rstrip('/')}/api/v1/chaos/trigger"
    payload = {
        "scenario": args.scenario,
        "namespace": args.namespace,
        "target_deployment": args.deployment
    }

    try:
        res = requests.post(endpoint, json=payload, timeout=5)
        if res.status_code == 200:
            data = res.json()
            print("✅ Incident successfully dispatched!")
            print(f"📌 Incident ID:         {data.get('incident_id')}")
            print(f"🤖 Recommended Action: {data.get('recommended_action')}")
            print(f"🎯 Confidence Score:   {data.get('confidence')}")
            print("Status:                Auto-Remediation Workflow Triggered.")
        else:
            print(f"❌ Error dispatching incident (HTTP {res.status_code}): {res.text}")
    except Exception as e:
        print(f"❌ Failed to reach AegisMind server at {args.url}: {e}")
        print("Tip: Make sure the server is running using `python app/src/api/server.py` or Docker.")

if __name__ == "__main__":
    main()
