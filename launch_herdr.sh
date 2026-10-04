#!/bin/bash

set -euo pipefail

# ---------------------------------------------------------------------------
# Clean slate: close all workspaces currently in this Herdr session.
# This removes Herdr layouts, not project files.
# ---------------------------------------------------------------------------

INITIAL_WORKSPACES="$(herdr workspace list)"
mapfile -t OLD_WS_IDS < <(
  jq -r '.result.workspaces[]?.workspace_id' <<<"$INITIAL_WORKSPACES"
)

for id in "${OLD_WS_IDS[@]}"; do
  herdr workspace close "$id"
done

# ---------------------------------------------------------------------------
# Ancillary workspace
# ---------------------------------------------------------------------------

ANCILLARY_CREATE="$(herdr workspace create --label ancillary)"
ANCILLARY_WS_ID="$(
  jq -er '.result.workspace.workspace_id' <<<"$ANCILLARY_CREATE"
)"
ANCILLARY_AUTO_TAB_ID="$(
  jq -er '.result.tab.tab_id' <<<"$ANCILLARY_CREATE"
)"

herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~/family --label family --no-focus
herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~/bd/testing/products --label testing --no-focus
herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~/JobSearch --label job-search --no-focus
herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~/.config/nvim --label configs --no-focus
herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~/finance_scripts --label finance --no-focus
herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~/CodingChallenges --label coding-challenge --no-focus
herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~/ProgrammingStudies/gospel/revelation_journal --label rev-journal --no-focus
herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~/embedded --label embedded --no-focus
herdr tab create --workspace "$ANCILLARY_WS_ID" --cwd ~ --label misc --no-focus

# workspace create made an initial tab; remove it now that the intended tabs exist.
herdr tab close "$ANCILLARY_AUTO_TAB_ID"

# ---------------------------------------------------------------------------
# Alaris workspace
# ---------------------------------------------------------------------------

ALARIS_CREATE="$(herdr workspace create --label alaris)"
ALARIS_WS_ID="$(
  jq -er '.result.workspace.workspace_id' <<<"$ALARIS_CREATE"
)"
ALARIS_AUTO_TAB_ID="$(
  jq -er '.result.tab.tab_id' <<<"$ALARIS_CREATE"
)"

herdr tab create --workspace "$ALARIS_WS_ID" --cwd ~/bd/stretch-work/productivity --label productivity --no-focus
herdr tab create --workspace "$ALARIS_WS_ID" --cwd ~/.pi --label pi --no-focus
herdr tab create --workspace "$ALARIS_WS_ID" --cwd /mnt/c/wsl/alaris-repos/device-alaris-embsw --label device-alaris-embsw --no-focus
herdr tab create --workspace "$ALARIS_WS_ID" --cwd /mnt/c/wsl/alaris-repos/device-alaris-embsw-dev-tests --label dev-tests --no-focus
herdr tab create --workspace "$ALARIS_WS_ID" --cwd /mnt/c/wsl/alaris-repos/build_BD9_platform_2.0.0.9 --label bd9-platform --no-focus
herdr tab create --workspace "$ALARIS_WS_ID" --cwd /mnt/c/wsl/alaris-repos/BD9_alarisIO --label bd9-alaris-io --no-focus
herdr tab create --workspace "$ALARIS_WS_ID" --cwd /mnt/c/wsl/tools/AlarisSimPackage --label simulators --no-focus
herdr tab create --workspace "$ALARIS_WS_ID" --cwd /mnt/c/wsl/alaris-repos --label cli --no-focus
herdr tab create --workspace "$ALARIS_WS_ID" --cwd /mnt/c/wsl/alaris-repos --label file --no-focus

# Remove the automatically created initial tab.
herdr tab close "$ALARIS_AUTO_TAB_ID"

# ---------------------------------------------------------------------------
# Verify the resulting Herdr layout
# ---------------------------------------------------------------------------

WORKSPACE_COUNT="$(
  herdr workspace list | jq -er '.result.workspaces | length'
)"
if [[ "$WORKSPACE_COUNT" -ne 2 ]]; then
  echo "Expected 2 workspaces; found $WORKSPACE_COUNT." >&2
  exit 1
fi

check_tab_count() {
  local workspace_id="$1"
  local expected="$2"
  local actual

  actual="$(
    herdr tab list --workspace "$workspace_id" |
      jq -er '.result.tabs | length'
  )"

  if [[ "$actual" -ne "$expected" ]]; then
    echo "Workspace $workspace_id: expected $expected tabs; found $actual." >&2
    exit 1
  fi
}

check_tab_count "$ANCILLARY_WS_ID" 9
check_tab_count "$ALARIS_WS_ID" 9

echo "Created and verified workspaces:"
echo "  ancillary: $ANCILLARY_WS_ID (9 tabs)"
echo "  alaris:    $ALARIS_WS_ID (9 tabs)"

read -n1 -p "Do you want to attach to herdr? (y/n) " confirmation
if [[ $confirmation == 'y' ]]; then
  herdr
else
  echo "Ok, just type 'herdr' whenever you're ready to attach to herdr sessions"
fi
