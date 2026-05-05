#!/bin/sh

# Generate SSH keys directly in 1Password and set machine hostname.

set -e

# --- Prompt user to proceed or skip ---
echo ""

CHOICE=$(printf '%s\n' "Set up SSH keys now" "Skip SSH key setup" | fzf \
  --header='Before continuing, open 1Password → Settings → Developer and enable:
  ✅ Show 1Password Developer experience
  ✅ Use the SSH Agent
  ✅ Integrate with 1Password CLI
  ✅ Check for developer credentials on disk

Select an option · ↑↓ navigate · enter confirm' \
  --height=10 \
  --no-multi \
  --reverse) || true

if [ "$CHOICE" != "Set up SSH keys now" ]; then
  echo "Skipping SSH key setup."
  exit 0
fi

# Verify 1Password CLI is available and signed in
check_op() {
    if ! command -v op >/dev/null 2>&1; then
        echo ""
        echo "1Password CLI (op) not found."
        echo "  In 1Password → Settings → Developer, click 'Integrate with 1Password CLI'"
        printf "Press Enter once installed, or 's' to skip SSH setup... "
        read -r OP_SKIP
        if [ "$OP_SKIP" = "s" ]; then
            echo "Skipping SSH key setup."
            exit 0
        fi
        check_op
        return
    fi

    if ! op account list >/dev/null 2>&1; then
        echo ""
        echo "1Password CLI is not signed in."
        printf "Sign in now? [Y/n/s] "
        read -r SIGNIN
        if [ "$SIGNIN" = "s" ]; then
            echo "Skipping SSH key setup."
            exit 0
        elif [ "${SIGNIN}" != "n" ] && [ "${SIGNIN}" != "N" ]; then
            eval "$(op signin)"
        fi
        check_op
        return
    fi
}

check_op

# --- Set hostname ---
CURRENT_HOSTNAME=$(hostname | sed 's/\.local$//')
echo ""
echo "Current hostname: ${CURRENT_HOSTNAME}"
printf "Set machine name (Allowed: alphanumeric a-z A-Z 0-9 and hyphens -): "
read -r MACHINE_NAME

if [ -n "$MACHINE_NAME" ]; then
    # Sanitize: strip invalid chars (allow a-z, A-Z, 0-9, hyphen), collapse hyphens
    MACHINE_NAME=$(echo "$MACHINE_NAME" | tr -cs 'a-zA-Z0-9-' '-' | sed 's/^-//;s/-$//')

    if [ -z "$MACHINE_NAME" ]; then
        echo "Invalid machine name — using current hostname."
        MACHINE_NAME="$CURRENT_HOSTNAME"
    else
        echo "Setting hostname to ${MACHINE_NAME}..."
        sudo scutil --set ComputerName "$MACHINE_NAME"
        sudo scutil --set LocalHostName "$MACHINE_NAME"
        sudo scutil --set HostName "$MACHINE_NAME"
    fi
else
    MACHINE_NAME="$CURRENT_HOSTNAME"
fi

AUTH_KEY_NAME="${MACHINE_NAME}"
SIGN_KEY_NAME="SSH Signing Key"

# --- Check for existing keys in 1Password ---
key_exists_in_1password() {
    op item list --categories "SSH Key" --format json 2>/dev/null \
        | python3 -c "import sys,json; sys.exit(0 if any(i['title']==sys.argv[1] for i in json.load(sys.stdin)) else 1)" "$1"
}
AUTH_EXISTS=$(key_exists_in_1password "$AUTH_KEY_NAME" && echo 1 || echo 0)
SIGN_EXISTS=$(key_exists_in_1password "$SIGN_KEY_NAME" && echo 1 || echo 0)

# --- Generate authentication key (per-machine) ---
if [ "$AUTH_EXISTS" -eq 0 ]; then
    echo ""
    echo "Generating authentication key '${AUTH_KEY_NAME}' in 1Password..."
    op item create --category "SSH Key" --title "$AUTH_KEY_NAME" --tags "ssh" >/dev/null
else
    echo ""
    echo "Authentication key '${AUTH_KEY_NAME}' already exists — skipping."
fi

# --- Signing key (shared across machines) ---
if [ "$SIGN_EXISTS" -eq 0 ]; then
    echo ""
    echo "Generating signing key '${SIGN_KEY_NAME}' in 1Password..."
    SIGN_ITEM=$(op item create --category "SSH Key" --title "$SIGN_KEY_NAME" --tags "ssh" --format json)
    SIGN_ITEM_ID=$(echo "$SIGN_ITEM" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
else
    echo ""
    echo "Signing key '${SIGN_KEY_NAME}' already exists — reusing."
    SIGN_ITEM=$(op item get "$SIGN_KEY_NAME" --format json)
    SIGN_ITEM_ID=$(echo "$SIGN_ITEM" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
fi

# --- Write signing key to gitconfig ---
echo ""
echo "Updating gitconfig with signing key..."
SIGNING_KEY=$(op item get "$SIGN_KEY_NAME" --field "public key" 2>/dev/null || true)
if [ -n "$SIGNING_KEY" ]; then
    git config --global user.signingkey "$SIGNING_KEY"
    echo "  Done."
else
    echo "  (skipped — could not read signing key from 1Password)"
fi

# --- Print public keys ---
echo ""
echo "=== SSH Key Setup Complete ==="
echo ""
echo "Authentication public key (${AUTH_KEY_NAME}):"
echo ""
op item get "$AUTH_KEY_NAME" --field "public key" 2>/dev/null || echo "(retrieve from 1Password)"
echo ""
echo "Signing public key (${SIGN_KEY_NAME}):"
echo ""
op item get "$SIGN_KEY_NAME" --field "public key" 2>/dev/null || echo "(retrieve from 1Password)"
echo ""

# --- Instructions ---
echo "--- Next Steps ---"
echo ""
echo "GitHub:"
echo "  1. Go to https://github.com/settings/keys"
echo "  2. Click 'New SSH key'"
echo "  3. Add the AUTHENTICATION key above as 'Authentication Key'"
echo "  4. Click 'New SSH key' again"
echo "  5. Add the SIGNING key above as 'Signing Key'"
echo ""
echo "GitLab:"
echo "  1. Go to https://gitlab.com/-/user_settings/ssh_keys"
echo "  2. Add the AUTHENTICATION key above"
echo "  3. Add the SIGNING key above"
echo ""
echo "1Password SSH Agent:"
echo "  Ensure both '${AUTH_KEY_NAME}' and '${SIGN_KEY_NAME}' are listed and enabled"
echo "  in 1Password → Settings → Developer → SSH Agent."
echo ""
printf "Press Enter to continue setup... "
read -r
