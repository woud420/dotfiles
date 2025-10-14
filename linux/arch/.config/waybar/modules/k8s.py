#!/usr/bin/env python3

import json
import subprocess
from collections import defaultdict

def run_command(cmd):
    """Run a shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
        return result.stdout.strip()
    except:
        return ""

def get_k8s_info():
    """Get Kubernetes context and detailed pod/app information"""
    context = run_command("kubectl config current-context 2>/dev/null")

    if not context:
        return None

    # Get namespace list
    namespaces_raw = run_command("kubectl get namespaces --no-headers -o custom-columns=':metadata.name' 2>/dev/null")
    namespaces = [ns.strip() for ns in namespaces_raw.split('\n') if ns.strip()]

    # Get all pods with namespace and status
    pods_raw = run_command("kubectl get pods --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase' --no-headers 2>/dev/null")

    # Parse pods by namespace
    pods_by_namespace = defaultdict(lambda: {"running": [], "pending": [], "failed": []})
    total_running = 0
    total_pending = 0
    total_failed = 0

    for line in pods_raw.split('\n'):
        if not line.strip():
            continue
        parts = line.split()
        if len(parts) >= 3:
            namespace, pod_name, status = parts[0], parts[1], parts[2]

            if status == "Running":
                pods_by_namespace[namespace]["running"].append(pod_name)
                total_running += 1
            elif status == "Pending":
                pods_by_namespace[namespace]["pending"].append(pod_name)
                total_pending += 1
            elif status in ["Failed", "Error", "CrashLoopBackOff"]:
                pods_by_namespace[namespace]["failed"].append(pod_name)
                total_failed += 1

    # Get node info
    nodes_ready = run_command("kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready'")
    try:
        nodes = int(nodes_ready) if nodes_ready else 0
    except:
        nodes = 0

    # Get deployments for better app understanding
    deployments_raw = run_command("kubectl get deployments --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,READY:.status.readyReplicas,TOTAL:.status.replicas' --no-headers 2>/dev/null")
    deployments = []
    for line in deployments_raw.split('\n'):
        if not line.strip():
            continue
        parts = line.split()
        if len(parts) >= 4:
            deployments.append({
                "namespace": parts[0],
                "name": parts[1],
                "ready": parts[2] if parts[2] != '<none>' else '0',
                "total": parts[3] if parts[3] != '<none>' else '0'
            })

    return {
        "context": context,
        "namespaces": namespaces,
        "pods_by_namespace": dict(pods_by_namespace),
        "pods_running": total_running,
        "pods_pending": total_pending,
        "pods_failed": total_failed,
        "nodes": nodes,
        "deployments": deployments
    }

def main():
    k8s_info = get_k8s_info()

    if not k8s_info:
        output = {
            "text": "☸ -",
            "tooltip": "Kubernetes: No context"
        }
        print(json.dumps(output))
        return

    # Build display text (context shown in tooltip only)
    text = f"☸ {k8s_info['pods_running']}"

    # Skip default Kubernetes namespaces
    system_namespaces = {'default', 'kube-system', 'kube-public', 'kube-node-lease', 'ingress-nginx'}

    # Build detailed tooltip
    tooltip_lines = [
        f"Context: {k8s_info['context']}",
        f"Nodes: {k8s_info['nodes']}",
        ""
    ]

    # Show deployments if any (excluding system namespaces)
    custom_deployments = [d for d in k8s_info['deployments'] if d['namespace'] not in system_namespaces]

    if custom_deployments:
        tooltip_lines.append("Deployments:")
        for dep in custom_deployments[:10]:  # Limit to 10
            tooltip_lines.append(f"  {dep['namespace']}/{dep['name']}: {dep['ready']}/{dep['total']}")
        if len(custom_deployments) > 10:
            tooltip_lines.append(f"  ... and {len(custom_deployments) - 10} more")
        tooltip_lines.append("")

    # Show pods grouped by namespace (only non-empty, non-system ones)
    tooltip_lines.append("Namespaces:")
    active_namespaces = 0
    for ns in k8s_info['namespaces']:
        # Skip system namespaces
        if ns in system_namespaces:
            continue

        pods = k8s_info['pods_by_namespace'].get(ns, {"running": [], "pending": [], "failed": []})
        running_count = len(pods['running'])
        pending_count = len(pods['pending'])
        failed_count = len(pods['failed'])

        status_parts = []
        if running_count > 0:
            status_parts.append(f"{running_count} running")
        if pending_count > 0:
            status_parts.append(f"{pending_count} pending")
        if failed_count > 0:
            status_parts.append(f"{failed_count} failed")

        if status_parts:
            tooltip_lines.append(f"  {ns}: {', '.join(status_parts)}")
            active_namespaces += 1

    if active_namespaces == 0:
        tooltip_lines.append("  (no custom namespaces)")

    # Add totals at bottom
    tooltip_lines.append("")
    tooltip_lines.append(f"Total: {k8s_info['pods_running']} running")
    if k8s_info['pods_pending'] > 0:
        tooltip_lines.append(f"       {k8s_info['pods_pending']} pending")
    if k8s_info['pods_failed'] > 0:
        tooltip_lines.append(f"       {k8s_info['pods_failed']} failed")

    tooltip = "\n".join(tooltip_lines)

    # Add CSS class if there are issues
    css_class = ""
    if k8s_info['pods_failed'] > 0:
        css_class = "critical"
    elif k8s_info['pods_pending'] > 0:
        css_class = "warning"

    output = {
        "text": text,
        "tooltip": tooltip,
        "class": css_class
    }

    print(json.dumps(output))

if __name__ == "__main__":
    main()
