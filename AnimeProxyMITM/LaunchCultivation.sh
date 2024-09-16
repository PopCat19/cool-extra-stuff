#!/usr/bin/bash
[ -z "$1" ] && d_name="animegame" || d_name="$1"
[ -z "$2" ] && d_size="1440x900" || d_size="$2"
[ -z "$3" ] && VERSION="3.1" || VERSION="$3"

# Set proxy
[ "$VERSION" = "melon" ] && PROXY="http://127.0.0.1:8081/" || PROXY="http://127.0.0.1:8080/"
echo "Using proxy address "$PROXY""

# Set environment variables
PROXY_ENV="http_proxy https_proxy ftp_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY"
for envar in $PROXY_ENV; do export $envar="$PROXY"; done
export WINEDEBUG="-all"

# Set commands
export WINEFSYNC="1" WINEESYNC="1"
export WINEPREFIX="/home/$USER/.local/share/lutris/runners/wine"
EXECUTABLE="prime-run cultivation" # Launcher command
MITM="mitmdump -s proxy.py" # MITM command

# Set $MITM cleanup for termination
cleanup() {
    echo "Terminating mitmdump..."
    pkill -15 mitmdump
    if pgrep -x "mitmdump" > /dev/null; then
        echo "mitmdump terminated!"
    else
        echo "mitmdump maybe terminated?"
    fi
}

# Call cleanup on keyboard interrupt
trap cleanup INT

# Execute stuff
echo "Starting..."
$MITM &
$EXECUTABLE

# Call cleanup when $EXECUTABLE exits
cleanup
