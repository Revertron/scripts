#!/bin/bash
# This script sums up all traffic for all Yggdrasil peers connected.

# This function converts values like "kb", "mb", "gb" to bytes
convert_to_bytes() {
    local size=$1
    if [[ $size =~ ([0-9]+)([kKmMgG]) ]]; then
        local num=${BASH_REMATCH[1]}
        local unit=${BASH_REMATCH[2]}

        case $unit in
            k|K) echo "$((num * 1024))" ;;
            m|M) echo "$((num * 1024 * 1024))" ;;
            g|G) echo "$((num * 1024 * 1024 * 1024))" ;;
        esac
    elif [[ $size =~ ^[0-9]+$ ]]; then
        # If it's a plain number with no suffix, assume bytes
        echo "$size"
    else
        echo "0"  # Return 0 for invalid or empty values
    fi
}

# Initialize total RX and TX
total_rx=0
total_tx=0

# Use `awk` to extract columns and process directly
while read -r rx tx; do
    # Convert RX and TX to bytes and accumulate
    total_rx=$((total_rx + $(convert_to_bytes "$rx")))
    total_tx=$((total_tx + $(convert_to_bytes "$tx")))
done < <(yggdrasilctl getpeers | awk '!/URI/ {print $7, $8}')

# Convert total bytes to MB
total_rx_mb=$((total_rx / 1024 / 1024))
total_tx_mb=$((total_tx / 1024 / 1024))

# Output the result
echo "Total RX: $total_rx_mb MB"
echo "Total TX: $total_tx_mb MB"
