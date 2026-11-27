#!/bin/bash

set -euo pipefail

FLATPAKS=/usr/share/flatpak-manager/flatpaks.txt
REMOTE=flathub

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root (e.g. with sudo)." >&2
    exit 1
fi

if [[ ! -r $FLATPAKS ]]; then
    echo "Cannot read $FLATPAKS" >&2
    exit 1
fi

desired=$(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$FLATPAKS" | sed '/^$/d' | sort -u)

if [[ -z $desired ]]; then
    echo "$FLATPAKS has no entries." >&2
    exit 1
fi

installed=$(flatpak list --system --app --columns=application | sed '/^$/d' | sort -u)

to_install=$(comm -23 <(echo "$desired") <(echo "$installed"))
to_remove=$(comm -13 <(echo "$desired") <(echo "$installed"))

# Remove apps that are not in the list
while read -r app; do
    [[ -z $app ]] && continue
    echo ">> Removing $app"
    flatpak uninstall --system -y --noninteractive "$app"
done <<< "$to_remove"

# Install missing apps
while read -r app; do
    [[ -z $app ]] && continue
    echo ">> Installing $app"
    flatpak install --system -y --noninteractive "$REMOTE" "$app"
done <<< "$to_install"

# Clean up runtimes no longer needed by any app
flatpak uninstall --system --unused -y --noninteractive

echo "Done."
