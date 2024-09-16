#!/usr/bin/bash
# Set proxy
PROXY="http://127.0.0.1:8080/"
echo "Using proxy address "$PROXY""

# Set environment variables
PROXY_ENV="http_proxy https_proxy ftp_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY"
for envar in $PROXY_ENV; do export $envar="$PROXY"; done
export WINEDEBUG="-all"

# Set commands
EXECUTABLE="lutris -d" # Launcher command

# Prompt user to start with mitmproxy
read -p "Start with mitmproxy? [Y/n] " answer
case ${answer:0:1} in
    y|Y|"" )
        MITM="mitmdump -s proxy.py" # MITM command
        USE_MITM=1
    ;;
    n|N )
        echo "Starting without mitmproxy."
        MITM=""
        USE_MITM=0
    ;;
    * )
        echo "Invalid input. Starting without mitmproxy."
        MITM=""
        USE_MITM=0
    ;;
esac

# Set $MITM cleanup for termination
cleanup() {
    if [ "$USE_MITM" -eq 1 ]; then
        echo "Terminating mitmdump..."
        pkill -15 mitmdump
        if pgrep -x "mitmdump" > /dev/null; then
            echo "mitmdump terminated!"
        else
            echo "mitmdump may have terminated."
        fi

    fi
}

# Call cleanup on keyboard interrupt
trap cleanup INT

# Execute stuff
echo "Starting..."
if [ "$USE_MITM" -eq 1 ]; then
    $MITM &
fi
$EXECUTABLE

# Call cleanup when $EXECUTABLE exits
cleanup
