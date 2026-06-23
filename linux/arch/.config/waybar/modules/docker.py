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

    # Get container names for tooltip
    containers = run_command("docker ps --format '{{.Names}}' 2>/dev/null")

    try:
        running = int(running) if running else 0
        total = int(total) if total else 0
    except:
        running, total = 0, 0

    return {
        "running": running,
        "total": total,
        "containers": containers.split('\n') if containers else []
    }

def main():
    docker_info = get_docker_info()

    # Build display text
    text = f"🐳 {docker_info['running']}"

    # Build detailed tooltip
    tooltip_lines = [f"Docker: {docker_info['running']}/{docker_info['total']} running"]

    if docker_info['containers']:
        tooltip_lines.append("\nRunning containers:")
        for container in docker_info['containers'][:10]:  # Limit to 10
            tooltip_lines.append(f"  • {container}")
        if len(docker_info['containers']) > 10:
            tooltip_lines.append(f"  ... and {len(docker_info['containers']) - 10} more")
    else:
        tooltip_lines.append("No containers running")

    tooltip = "\n".join(tooltip_lines)

    output = {
        "text": text,
        "tooltip": tooltip
    }

    print(json.dumps(output))

if __name__ == "__main__":
    main()
