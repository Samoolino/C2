#!/usr/bin/env bash
# Read-only workstation discovery for C2. Does not install, stop, modify, or delete.
set -u

section() { printf '\n===== %s =====\n' "$1"; }

section "Host and OS"
printf 'Date: '; date -Is 2>/dev/null || date
printf 'Kernel: '; uname -a
printf 'Distro: '; grep -E '^(NAME|VERSION)=' /etc/os-release 2>/dev/null | tr '\n' ' '; printf '\n'
printf 'User: %s\n' "${USER:-unknown}"
printf 'Home: %s\n' "${HOME:-unknown}"
printf 'WSL: %s\n' "${WSL_DISTRO_NAME:-not-detected}"

section "Disk capacity"
df -h "$HOME" / 2>/dev/null || true

section "Runtime versions"
for cmd in git docker docker-compose make python3 node npm pnpm uv tailscale; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '%-16s %s\n' "$cmd" "$(command -v "$cmd")"
    case "$cmd" in
      git) git --version 2>/dev/null ;;
      docker) docker --version 2>/dev/null ;;
      docker-compose) docker-compose version 2>/dev/null | head -n 1 ;;
      python3) python3 --version 2>/dev/null ;;
      node) node --version 2>/dev/null ;;
      npm) npm --version 2>/dev/null ;;
      pnpm) pnpm --version 2>/dev/null ;;
      uv) uv --version 2>/dev/null ;;
      tailscale) tailscale version 2>/dev/null | head -n 1 ;;
    esac
  else
    printf '%-16s %s\n' "$cmd" "not found"
  fi
done

section "Docker daemon and containers"
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  docker info --format 'Docker server={{.ServerVersion}}; OS={{.OperatingSystem}}; CPUs={{.NCPU}}; MemoryBytes={{.MemTotal}}' 2>/dev/null || true
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || true
  printf '\nCompose projects:\n'
  docker compose ls -a 2>/dev/null || true
  printf '\nRelevant volume names (names only):\n'
  docker volume ls --format '{{.Name}}' 2>/dev/null | grep -Ei 'hummingbot|condor|gateway|postgres|emqx|redis' || true
  printf '\nRelevant networks (names only):\n'
  docker network ls --format '{{.Name}}' 2>/dev/null | grep -Ei 'hummingbot|condor|gateway' || true
else
  echo "Docker daemon unavailable or Docker CLI missing."
fi

section "Candidate project directories"
for base in "$HOME" "$HOME/projects" "$HOME/workspace" "$HOME/dev" /opt; do
  [ -d "$base" ] || continue
  find "$base" -maxdepth 3 -type d \( -iname '*hummingbot*' -o -iname '*condor*' -o -iname '*gateway*' \) -print 2>/dev/null | head -n 100
done

section "Git repositories in candidate directories"
for base in "$HOME" "$HOME/projects" "$HOME/workspace" "$HOME/dev" /opt; do
  [ -d "$base" ] || continue
  find "$base" -maxdepth 4 -type d -name .git -print 2>/dev/null | head -n 100 | while IFS= read -r gitdir; do
    repo="${gitdir%/.git}"
    printf '\nRepository: %s\n' "$repo"
    git -C "$repo" remote -v 2>/dev/null | sed -E 's#(https?://)[^/@]+:[^/@]+@#\1[REDACTED]@#g' | head -n 4
    printf 'Branch: '; git -C "$repo" branch --show-current 2>/dev/null || true
    printf 'Status: '; git -C "$repo" status --short 2>/dev/null | head -n 20
  done
done

section "Listening ports (best effort)"
if command -v ss >/dev/null 2>&1; then
  ss -lnt 2>/dev/null | awk 'NR==1 || /:(8000|8088|5432|1883|18083|15888|3000|8080)[[:space:]]/'
fi

section "Tailscale status (device names and IPs may be sensitive)"
if command -v tailscale >/dev/null 2>&1; then
  tailscale status 2>/dev/null | sed -E 's/[0-9]{1,3}(\.[0-9]{1,3}){3}/[IP-REDACTED]/g' || true
else
  echo "Tailscale CLI not found."
fi

section "Completion"
echo "Read-only inventory complete. No containers, volumes, repositories, credentials, or services were changed."
echo "Before sharing output, review it for usernames, hostnames, repository paths, IPs, and other identifying information."
