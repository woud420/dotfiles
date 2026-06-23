#!/usr/bin/env python3

import json
import subprocess

def run_command(cmd):
    """Run a shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
        return result.stdout.strip()
    except:
        return ""

def get_docker_info():
    """Get Docker container information"""
    running = run_command("docker ps -q 2>/dev/null | wc -l")
    total = run_command("docker ps -aq 2>/dev/null | wc -l")

    try:
        running = int(running) if running else 0
        total = int(total) if total else 0
    except:
        running, total = 0, 0

    return {"running": running, "total": total}

def get_k8s_info():
    """Get Kubernetes context and pod information"""
    context = run_command("kubectl config current-context 2>/dev/null")

    if not context:
        return None

    # Get pod counts by status
    pods_running = run_command("kubectl get pods --all-namespaces --field-selector=status.phase=Running 2>/dev/null | tail -n +2 | wc -l")
    pods_pending = run_command("kubectl get pods --all-namespaces --field-selector=status.phase=Pending 2>/dev/null | tail -n +2 | wc -l")
    pods_failed = run_command("kubectl get pods --all-namespaces --field-selector=status.phase=Failed 2>/dev/null | tail -n +2 | wc -l")

    try:
        running = int(pods_running) if pods_running else 0
        pending = int(pods_pending) if pods_pending else 0
        failed = int(pods_failed) if pods_failed else 0
    except:
        running, pending, failed = 0, 0, 0

    return {
        "context": context,
        "pods_running": running,
        "pods_pending": pending,
        "pods_failed": failed,
        "pods_total": running + pending + failed
    }

def main():
    docker_info = get_docker_info()
    k8s_info = get_k8s_info()

    # Build display text
    if k8s_info:
        # Shorten context if too long
        context = k8s_info['context']
        short_context = f"{context[:12]}..." if len(context) > 15 else context

        text = f"🐳 {docker_info['running']} ☸ {k8s_info['pods_running']} ({short_context})"
    else:
        text = f"🐳 {docker_info['running']}"

    # Build tooltip
    tooltip_lines = []
    tooltip_lines.append(f"Docker: {docker_info['running']}/{docker_info['total']} running")

    if k8s_info:
        tooltip_lines.append(f"Context: {k8s_info['context']}")
        tooltip_lines.append(f"Pods Running: {k8s_info['pods_running']}")
        if k8s_info['pods_pending'] > 0:
            tooltip_lines.append(f"Pods Pending: {k8s_info['pods_pending']}")
        if k8s_info['pods_failed'] > 0:
            tooltip_lines.append(f"Pods Failed: {k8s_info['pods_failed']}")
    else:
        tooltip_lines.append("Kubernetes: No context")

    tooltip = "\n".join(tooltip_lines)

    # Add CSS class if there are issues
    css_class = ""
    if k8s_info and k8s_info['pods_failed'] > 0:
        css_class = "critical"
    elif k8s_info and k8s_info['pods_pending'] > 0:
        css_class = "warning"

    output = {
        "text": text,
        "tooltip": tooltip,
        "class": css_class
    }

    print(json.dumps(output))

if __name__ == "__main__":
    main()
