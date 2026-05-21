#!/bin/bash

# ═══════════════════════════════════════════════
#   SECURE FILE VAULT SYSTEM
#   OS Lab Project — Bash + Whiptail TUI
#   Linux Shell Language
# ═══════════════════════════════════════════════

VAULT_DIR="$HOME/SecureVault/vault"
USERS_FILE="$HOME/SecureVault/users.txt"
LOG_FILE="$HOME/SecureVault/logs.txt"

# Encryption keys
XOR_KEY=42
CAESAR_KEY=7
VIGENERE_KEY="OSLAB"
RAIL_FENCE_RAILS=3

# ─── SETUP DEFAULT USER ─────────────────────────
setup() {
    mkdir -p "$VAULT_DIR/images" "$VAULT_DIR/documents" \
             "$VAULT_DIR/audio"  "$VAULT_DIR/video" \
             "$VAULT_DIR/others"
    if [ ! -s "$USERS_FILE" ]; then
        echo "admin:admin123" > "$USERS_FILE"
    fi
}

# ─── LOGGING ────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ════════════════════════════════════════════════
#   ENCRYPTION METHODS (4 LAYERS)
# ════════════════════════════════════════════════

# ─── METHOD 1: XOR CIPHER ───────────────────────
encrypt_xor() {
    local input="$1" output="$2"
    python3 -c "
xor_key = $XOR_KEY
with open('$input', 'rb') as f:
    data = bytearray(f.read())
for i in range(len(data)):
    data[i] ^= xor_key
with open('$output', 'wb') as f:
    f.write(data)
"
}

decrypt_xor() {
    local input="$1" output="$2"
    # XOR is symmetric — same operation decrypts
    encrypt_xor "$input" "$output"
}

# ─── METHOD 2: CAESAR + BLOCK REVERSAL ──────────
encrypt_caesar_block() {
    local input="$1" output="$2"
    python3 -c "
caesar_key = $CAESAR_KEY
with open('$input', 'rb') as f:
    data = bytearray(f.read())
for i in range(len(data)):
    data[i] = (data[i] + caesar_key + (i % 5)) % 256
block = 8
for i in range(0, len(data) - block + 1, block):
    data[i:i+block] = data[i:i+block][::-1]
with open('$output', 'wb') as f:
    f.write(data)
"
}

decrypt_caesar_block() {
    local input="$1" output="$2"
    python3 -c "
caesar_key = $CAESAR_KEY
with open('$input', 'rb') as f:
    data = bytearray(f.read())
block = 8
for i in range(0, len(data) - block + 1, block):
    data[i:i+block] = data[i:i+block][::-1]
for i in range(len(data)):
    data[i] = (data[i] - caesar_key - (i % 5)) % 256
with open('$output', 'wb') as f:
    f.write(data)
"
}

# ─── METHOD 3: VIGENÈRE CIPHER ──────────────────
encrypt_vigenere() {
    local input="$1" output="$2"
    python3 -c "
key = b'$VIGENERE_KEY'
key_len = len(key)
with open('$input', 'rb') as f:
    data = bytearray(f.read())
for i in range(len(data)):
    shift = key[i % key_len]
    data[i] = (data[i] + shift) % 256
with open('$output', 'wb') as f:
    f.write(data)
"
}

decrypt_vigenere() {
    local input="$1" output="$2"
    python3 -c "
key = b'$VIGENERE_KEY'
key_len = len(key)
with open('$input', 'rb') as f:
    data = bytearray(f.read())
for i in range(len(data)):
    shift = key[i % key_len]
    data[i] = (data[i] - shift) % 256
with open('$output', 'wb') as f:
    f.write(data)
"
}

# ─── METHOD 4: BYTE ROTATION CIPHER ─────────────
# Rotates each byte left by (position % 8) bits
encrypt_rotate() {
    local input="$1" output="$2"
    python3 -c "
with open('$input', 'rb') as f:
    data = bytearray(f.read())
for i in range(len(data)):
    rot = i % 8
    b = data[i]
    data[i] = ((b << rot) | (b >> (8 - rot))) & 0xFF
with open('$output', 'wb') as f:
    f.write(data)
"
}

decrypt_rotate() {
    local input="$1" output="$2"
    python3 -c "
with open('$input', 'rb') as f:
    data = bytearray(f.read())
for i in range(len(data)):
    rot = i % 8
    b = data[i]
    data[i] = ((b >> rot) | (b << (8 - rot))) & 0xFF
with open('$output', 'wb') as f:
    f.write(data)
"
}

# ─── COMBINED ENCRYPT (all chosen methods) ───────
encrypt_file() {
    local input="$1"
    local output="$2"
    local methods="$3"   # e.g. "1,2,4"
    local tmp1 tmp2
    tmp1=$(mktemp)
    tmp2=$(mktemp)

    cp "$input" "$tmp1"

    IFS=',' read -ra chosen <<< "$methods"
    for m in "${chosen[@]}"; do
        case "$m" in
            1) encrypt_xor          "$tmp1" "$tmp2" ;;
            2) encrypt_caesar_block "$tmp1" "$tmp2" ;;
            3) encrypt_vigenere     "$tmp1" "$tmp2" ;;
            4) encrypt_rotate       "$tmp1" "$tmp2" ;;
        esac
        cp "$tmp2" "$tmp1"
    done

    cp "$tmp1" "$output"
    rm -f "$tmp1" "$tmp2"
}

# ─── COMBINED DECRYPT (reverse order) ────────────
decrypt_file() {
    local input="$1"
    local output="$2"
    local methods="$3"   # same string that was used during encryption
    local tmp1 tmp2
    tmp1=$(mktemp)
    tmp2=$(mktemp)

    cp "$input" "$tmp1"

    # Reverse the method order for decryption
    IFS=',' read -ra chosen <<< "$methods"
    local reversed=()
    for (( idx=${#chosen[@]}-1; idx>=0; idx-- )); do
        reversed+=("${chosen[$idx]}")
    done

    for m in "${reversed[@]}"; do
        case "$m" in
            1) decrypt_xor          "$tmp1" "$tmp2" ;;
            2) decrypt_caesar_block "$tmp1" "$tmp2" ;;
            3) decrypt_vigenere     "$tmp1" "$tmp2" ;;
            4) decrypt_rotate       "$tmp1" "$tmp2" ;;
        esac
        cp "$tmp2" "$tmp1"
    done

    cp "$tmp1" "$output"
    rm -f "$tmp1" "$tmp2"
}

# ─── GET SUBFOLDER BY FILE TYPE ─────────────────
get_subfolder() {
    local filename="$1"
    local ext="${filename##*.}"
    ext="${ext,,}"
    case "$ext" in
        jpg|jpeg|png|bmp|gif|svg|webp) echo "$VAULT_DIR/images/" ;;
        txt|pdf|docx|odt|doc|xlsx|csv|pptx) echo "$VAULT_DIR/documents/" ;;
        mp3|wav|flac|aac|ogg) echo "$VAULT_DIR/audio/" ;;
        mp4|avi|mkv|mov|webm) echo "$VAULT_DIR/video/" ;;
        *)                    echo "$VAULT_DIR/others/" ;;
    esac
}

# ─── SAVE METHODS METADATA ───────────────────────
save_methods_meta() {
    local encpath="$1" methods="$2"
    echo "$methods" > "${encpath}.meta"
}

load_methods_meta() {
    local encpath="$1"
    if [ -f "${encpath}.meta" ]; then
        cat "${encpath}.meta"
    else
        # Fallback: assume all 4 methods were applied in order
        echo "1,2,3,4"
    fi
}

# ════════════════════════════════════════════════
#   AUTHENTICATION  (whiptail)
# ════════════════════════════════════════════════
authenticate() {
    local username password

    username=$(whiptail --inputbox "Enter Username:" 8 40 \
        --title "Secure File Vault" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && exit 0

    password=$(whiptail --passwordbox "Enter Password:" 8 40 \
        --title "Secure File Vault" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && exit 0

    if grep -qx "$username:$password" "$USERS_FILE"; then
        log "LOGIN SUCCESS: $username"
        whiptail --msgbox "Welcome, $username!" 8 30 --title "Login"
        CURRENT_USER="$username"
        return 0
    else
        log "LOGIN FAILED: $username"
        whiptail --msgbox "Invalid username or password!" 8 40 --title "Error"
        return 1
    fi
}

# ════════════════════════════════════════════════
#   ADD FILE
# ════════════════════════════════════════════════
add_file() {
    # ── Step 1: pick file path ──
    local filepath
    filepath=$(whiptail --inputbox \
        "Enter the FULL path of the file to add:\n(e.g. /home/user/Documents/report.pdf)" \
        10 60 "" --title "Add File to Vault" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return
    [ ! -f "$filepath" ] && whiptail --msgbox "File not found: $filepath" 8 50 && return

    # ── Step 2: choose encryption methods (checklist) ──
    local chosen_methods
    chosen_methods=$(whiptail --checklist \
        "Choose Encryption Methods (SPACE to select, at least one required):" \
        18 60 4 \
        "1" "XOR Cipher          (key=42)"          ON  \
        "2" "Caesar + Block Rev  (key=7, block=8)"  ON  \
        "3" "Vigenère Cipher     (key=OSLAB)"        OFF \
        "4" "Byte Rotation       (pos-based rotate)" OFF \
        --title "Select Encryption Layers" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    # Convert whiptail output '"1" "3"' → "1,3"
    local methods
    methods=$(echo "$chosen_methods" | tr -d '"' | tr ' ' ',')

    if [ -z "$methods" ]; then
        whiptail --msgbox "No method selected. Cancelling." 8 40
        return
    fi

    local filename subfolder destpath
    filename=$(basename "$filepath")
    subfolder=$(get_subfolder "$filename")
    destpath="${subfolder}${filename}.enc"

    # ── Step 3: encrypt ──
    encrypt_file "$filepath" "$destpath" "$methods"
    save_methods_meta "$destpath" "$methods"

    # ── Step 4: terminal report ──
    local method_names=""
    IFS=',' read -ra arr <<< "$methods"
    for m in "${arr[@]}"; do
        case "$m" in
            1) method_names+="  Layer: XOR Cipher (key=$XOR_KEY)\n" ;;
            2) method_names+="  Layer: Caesar + Block Reversal (key=$CAESAR_KEY, block=8)\n" ;;
            3) method_names+="  Layer: Vigenère Cipher (key=$VIGENERE_KEY)\n" ;;
            4) method_names+="  Layer: Byte Rotation Cipher\n" ;;
        esac
    done

    echo ""
    echo "================================================"
    echo "  FILE ADDED: $filename"
    echo "================================================"
    if file "$filepath" | grep -q "text"; then
        echo "  Original content preview:"
        echo "  ----------------------------------------"
        head -5 "$filepath" | sed 's/^/  /'
        echo "  ----------------------------------------"
    else
        echo "  (Binary file — content preview skipped)"
    fi
    echo ""
    printf "  Encryption layers applied:\n$method_names"
    echo ""
    echo "  Encrypted bytes preview (xxd):"
    echo "  ----------------------------------------"
    xxd "$destpath" | head -8 | sed 's/^/  /'
    echo "  ----------------------------------------"
    echo "  Stored in: $subfolder"
    echo "================================================"
    echo ""

    log "FILE ADDED: $filename [methods=$methods] by $CURRENT_USER"
    whiptail --msgbox "File encrypted and stored!\n\nMethods used: $methods\nCheck the terminal for byte preview." \
        12 55 --title "File Added"
}

# ════════════════════════════════════════════════
#   VIEW FILES
# ════════════════════════════════════════════════
view_files() {
    local list_args=()
    local category file name size icon

    for category in images documents audio video others; do
        for file in "$VAULT_DIR/$category/"*.enc; do
            [ -f "$file" ] || continue
            name=$(basename "$file" .enc)
            size=$(du -sh "$file" 2>/dev/null | cut -f1)
            methods=$(load_methods_meta "$file")
            list_args+=("$name" "$category" "$size" "$methods")
        done
    done

    if [ ${#list_args[@]} -eq 0 ]; then
        whiptail --msgbox "Vault is empty. Add some files first!" 8 40 --title "Vault Files"
    else
        whiptail --menu "Files in your Vault:" 20 70 10 \
            "${list_args[@]}" \
            --title "Vault Contents" 3>&1 1>&2 2>&3
    fi

    log "VIEWED file list by $CURRENT_USER"
}

# ════════════════════════════════════════════════
#   DECRYPT FILE (TEMP ACCESS)
# ════════════════════════════════════════════════
decrypt_file_gui() {
    local encpath outpath seconds filename methods

    encpath=$(whiptail --inputbox \
        "Enter the FULL path of the encrypted (.enc) file:" \
        9 65 "$VAULT_DIR/" \
        --title "Decrypt File" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return
    [ ! -f "$encpath" ] && whiptail --msgbox "File not found!" 8 40 && return

    filename=$(basename "$encpath" .enc)
    outpath="/tmp/$filename"

    methods=$(load_methods_meta "$encpath")

    decrypt_file "$encpath" "$outpath" "$methods"

    seconds=$(whiptail --inputbox \
        "Auto-delete decrypted copy after how many seconds? (10-300):" \
        9 55 "60" --title "Temp Access Timer" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && seconds=60
    [[ ! "$seconds" =~ ^[0-9]+$ ]] && seconds=60

    (
        sleep "$seconds"
        rm -f "$outpath"
        log "AUTO-DELETED temp file: $filename after ${seconds}s"
    ) &

    xdg-open "$outpath" 2>/dev/null || \
        whiptail --msgbox "Cannot auto-open. Find the file at:\n$outpath" 10 55

    log "FILE DECRYPTED (temp ${seconds}s): $filename by $CURRENT_USER"
    whiptail --msgbox \
        "File opened!\n\nAuto-deletes in $seconds seconds.\nLocation: $outpath\nMethods used to decrypt: $methods" \
        12 55 --title "Temp Access"
}

# ════════════════════════════════════════════════
#   VIEW LOGS
# ════════════════════════════════════════════════
view_logs() {
    if [ ! -s "$LOG_FILE" ]; then
        whiptail --msgbox "No logs yet." 8 30 --title "Activity Logs"
    else
        whiptail --textbox "$LOG_FILE" 22 70 --title "Activity Logs"
    fi
}

# ════════════════════════════════════════════════
#   CHANGE PASSWORD
# ════════════════════════════════════════════════
change_password() {
    local newpass confirm

    newpass=$(whiptail --passwordbox "Enter New Password:" 8 40 \
        --title "Change Password" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    confirm=$(whiptail --passwordbox "Confirm New Password:" 8 40 \
        --title "Change Password" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return

    if [ "$newpass" = "$confirm" ]; then
        grep -v "^$CURRENT_USER:" "$USERS_FILE" > /tmp/users_tmp
        echo "$CURRENT_USER:$newpass" >> /tmp/users_tmp
        mv /tmp/users_tmp "$USERS_FILE"
        log "PASSWORD CHANGED: $CURRENT_USER"
        whiptail --msgbox "Password changed successfully!" 8 40
    else
        whiptail --msgbox "Passwords do not match!" 8 40 --title "Error"
    fi
}

# ════════════════════════════════════════════════
#   MAIN MENU
# ════════════════════════════════════════════════
main_menu() {
    while true; do
        choice=$(whiptail --menu \
            "Logged in as: $CURRENT_USER" \
            18 50 7 \
            "1" "Add File to Vault" \
            "2" "View Vault Files" \
            "3" "Decrypt File (Temp Access)" \
            "4" "View Activity Logs" \
            "5" "Change Password" \
            "6" "Logout" \
            --title "Secure File Vault" 3>&1 1>&2 2>&3)

        [ $? -ne 0 ] && break

        case "$choice" in
            1) add_file ;;
            2) view_files ;;
            3) decrypt_file_gui ;;
            4) view_logs ;;
            5) change_password ;;
            6) break ;;
        esac
    done
}

# ════════════════════════════════════════════════
#   ENTRY POINT
# ════════════════════════════════════════════════
setup
if authenticate; then
    main_menu
fi