#!/bin/zsh

# Image metadata extractor script for macOS
# Usage: ./list-files.zsh [source_folder] [-b]
#   -b: Display file sizes in bytes instead of human-readable format

# Set default values
# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SOURCE_FOLDER="${1:-$SCRIPT_DIR}"

# Check for -b flag
BYTES_MODE=false
if [[ "$1" == "-b" ]]; then
    BYTES_MODE=true
    SOURCE_FOLDER="${2:-$SCRIPT_DIR}"
elif [[ "$2" == "-b" ]]; then
    BYTES_MODE=true
fi

# Check if source folder exists
if [[ ! -d "$SOURCE_FOLDER" ]]; then
    echo "Error: Source folder '$SOURCE_FOLDER' does not exist."
    echo "Usage: $0 [source_folder] [-b]"
    echo "  -b: Display file sizes in bytes instead of human-readable format"
    exit 1
fi

# Function to convert bytes to human readable format
format_bytes() {
    local bytes=$1
    if [[ "$BYTES_MODE" == "true" ]]; then
        printf "%d" $bytes
    elif [[ $bytes -gt 1073741824 ]]; then
        printf "%.2f GB" $(echo "$bytes / 1073741824" | bc -l)
    elif [[ $bytes -gt 1048576 ]]; then
        printf "%.2f MB" $(echo "$bytes / 1048576" | bc -l)
    elif [[ $bytes -gt 1024 ]]; then
        printf "%.2f KB" $(echo "$bytes / 1024" | bc -l)
    else
        printf "%d B" $bytes
    fi
}

# Function to calculate aspect ratio
calculate_aspect_ratio() {
    local width=$1
    local height=$2
    
    if [[ $height -eq 0 ]]; then
        echo "N/A"
        return
    fi
    
    # Use bc for floating point arithmetic
    local ratio=$(echo "scale=2; $width / $height" | bc -l)
    echo "$ratio"
}

# Function to print table header
print_table_header() {
    printf "%-30s %-12s %-10s %-10s %-12s %-8s %-10s %-8s %-10s\n" "Filename" "Size" "Width" "Height" "Aspect Ratio" "PPI" "File Type" "Bit Depth" "Color Space"
    printf "%-30s %-12s %-10s %-10s %-12s %-8s %-10s %-8s %-10s\n" "--------" "----" "-----" "------" "------------" "---" "---------" "---------" "----------"
}

# Function to print table row
print_table_row() {
    local name="$1"
    local size="$2"
    local width="$3"
    local height="$4"
    local aspect="$5"
    local ppi="$6"
    local filetype="$7"
    local bitdepth="$8"
    local colorspace="$9"
    
    # Truncate long filenames
    local short_name=$(echo "$name" | cut -c1-28)
    if [[ ${#name} -gt 28 ]]; then
        short_name="$short_name..."
    fi
    
    printf "%-30s %-12s %-10s %-10s %-12s %-8s %-10s %-8s %-10s\n" "$short_name" "$size" "$width" "$height" "$aspect" "$ppi" "$filetype" "$bitdepth" "$colorspace"
}

# Function to print CSV header
print_csv_header() {
    echo "Filename,Size,Width,Height,Aspect Ratio,PPI,File Type,Bit Depth,Color Space"
}

# Function to print CSV row
print_csv_row() {
    local name="$1"
    local size="$2"
    local width="$3"
    local height="$4"
    local aspect="$5"
    local ppi="$6"
    local filetype="$7"
    local bitdepth="$8"
    local colorspace="$9"
    
    # Escape commas in CSV fields
    local name_escaped=$(echo "$name" | sed 's/,/\\,/g')
    local size_escaped=$(echo "$size" | sed 's/,/\\,/g')
    local filetype_escaped=$(echo "$filetype" | sed 's/,/\\,/g')
    local colorspace_escaped=$(echo "$colorspace" | sed 's/,/\\,/g')
    
    echo "$name_escaped,$size_escaped,$width,$height,$aspect,$ppi,$filetype_escaped,$bitdepth,$colorspace_escaped"
}

# Ask user for output preference
echo "Image Metadata Extractor"
echo "========================"
echo ""
echo "Choose output format:"
echo "1) Display table in terminal"
echo "2) Save as CSV file"
echo ""
echo -n "Enter your choice (1 or 2): "
read choice

# Validate choice
if [[ "$choice" != "1" && "$choice" != "2" ]]; then
    echo "Invalid choice. Please run the script again and select 1 or 2."
    exit 1
fi

# Set output mode
if [[ "$choice" == "1" ]]; then
    OUTPUT_MODE="table"
    echo "Output mode: Display table"
else
    OUTPUT_MODE="csv"
    CSV_FILENAME="$SCRIPT_DIR/image_metadata.csv"
    echo "Output mode: Save as CSV"
    echo "CSV will be saved as: $CSV_FILENAME"
fi

echo ""
echo "Scanning for image files in: $SOURCE_FOLDER"
echo ""

# Print header based on mode
if [[ "$OUTPUT_MODE" == "table" ]]; then
    print_table_header
else
    print_csv_header > "$CSV_FILENAME"
fi

# Process files with optimized find command and parallel processing
find "$SOURCE_FOLDER" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.gif" -o \
    -iname "*.bmp" -o \
    -iname "*.tiff" -o \
    -iname "*.tif" -o \
    -iname "*.webp" -o \
    -iname "*.heic" -o \
    -iname "*.heif" \
\) -print0 | xargs -0 -P 4 -I {} sh -c '
    file="$1"
    filename=$(basename "$file")
    output_mode="$2"
    csv_filename="$3"
    bytes_mode="$4"
    
    # Get file size
    filesize=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    
    # Convert to human readable format or bytes
    if [ "$bytes_mode" = "true" ]; then
        filesize_formatted=$(printf "%d" "$filesize")
    elif [ "$filesize" -gt 1073741824 ]; then
        filesize_formatted=$(printf "%.2f GB" $(echo "$filesize / 1073741824" | bc -l))
    elif [ "$filesize" -gt 1048576 ]; then
        filesize_formatted=$(printf "%.2f MB" $(echo "$filesize / 1048576" | bc -l))
    elif [ "$filesize" -gt 1024 ]; then
        filesize_formatted=$(printf "%.2f KB" $(echo "$filesize / 1024" | bc -l))
    else
        filesize_formatted=$(printf "%d B" "$filesize")
    fi
    
    # Get file type from extension
    file_extension=$(echo "$filename" | sed "s/.*\.//" | tr "[:lower:]" "[:upper:]")
    case "$file_extension" in
        JPG|JPEG) filetype="JPEG" ;;
        PNG) filetype="PNG" ;;
        GIF) filetype="GIF" ;;
        BMP) filetype="BMP" ;;
        TIFF|TIF) filetype="TIFF" ;;
        WEBP) filetype="WEBP" ;;
        HEIC) filetype="HEIC" ;;
        HEIF) filetype="HEIF" ;;
        *) filetype="UNKNOWN" ;;
    esac
    
    # Get image dimensions and bit depth using sips
    sips_output=$(sips -g pixelWidth -g pixelHeight -g dpiWidth -g bitsPerSample -g space "$file" 2>/dev/null)
    
    if [ -n "$sips_output" ]; then
        # Extract width, height, and PPI
        width=$(echo "$sips_output" | grep "pixelWidth" | awk "{print \$2}")
        height=$(echo "$sips_output" | grep "pixelHeight" | awk "{print \$2}")
        ppi=$(echo "$sips_output" | grep "dpiWidth" | awk "{print \$2}")
        bits_per_sample=$(echo "$sips_output" | grep "bitsPerSample" | awk "{print \$2}")
        colorspace=$(echo "$sips_output" | grep "space" | awk "{print \$2}")
        
        if [ -n "$width" ] && [ -n "$height" ]; then
            # Calculate aspect ratio
            if [ "$height" -eq 0 ]; then
                aspect_ratio="N/A"
            else
                aspect_ratio=$(echo "scale=2; $width / $height" | bc -l)
            fi
            
            # Check PPI
            if [ -z "$ppi" ] || [ "$ppi" = "0" ]; then
                ppi="N/A"
            fi
            
            # Calculate bit depth from bits per sample
            if [ -n "$bits_per_sample" ] && [ "$bits_per_sample" != "0" ]; then
                if [ "$filetype" = "JPEG" ] || [ "$filetype" = "PNG" ] || [ "$filetype" = "WEBP" ]; then
                    bitdepth=$(echo "$bits_per_sample * 3" | bc)
                elif [ "$filetype" = "GIF" ]; then
                    bitdepth="8"
                elif [ "$filetype" = "TIFF" ]; then
                    bitdepth=$(echo "$bits_per_sample * 3" | bc)
                else
                    bitdepth="$bits_per_sample"
                fi
            else
                case "$filetype" in
                    JPEG) bitdepth="24" ;;
                    PNG) bitdepth="24" ;;
                    GIF) bitdepth="8" ;;
                    BMP) bitdepth="24" ;;
                    TIFF) bitdepth="24" ;;
                    WEBP) bitdepth="24" ;;
                    HEIC|HEIF) bitdepth="24" ;;
                    *) bitdepth="N/A" ;;
                esac
            fi
            
            # Process color space information
            if [ -n "$colorspace" ] && [ "$colorspace" != "0" ]; then
                colorspace_display="$colorspace"
            else
                colorspace_display="N/A"
            fi
            
            # Output based on mode
            if [ "$output_mode" = "table" ]; then
                short_name=$(echo "$filename" | cut -c1-28)
                if [ ${#filename} -gt 28 ]; then
                    short_name="$short_name..."
                fi
                printf "%-30s %-12s %-10s %-10s %-12s %-8s %-10s %-8s %-10s\n" "$short_name" "$filesize_formatted" "$width" "$height" "$aspect_ratio" "$ppi" "$filetype" "$bitdepth" "$colorspace_display"
            else
                name_escaped=$(echo "$filename" | sed "s/,/\\,/g")
                size_escaped=$(echo "$filesize_formatted" | sed "s/,/\\,/g")
                filetype_escaped=$(echo "$filetype" | sed "s/,/\\,/g")
                colorspace_escaped=$(echo "$colorspace_display" | sed "s/,/\\,/g")
                echo "$name_escaped,$size_escaped,$width,$height,$aspect_ratio,$ppi,$filetype_escaped,$bitdepth,$colorspace_escaped" >> "$csv_filename"
            fi
        else
            echo "Warning: Could not extract dimensions from $filename" >&2
        fi
    else
        echo "Warning: Could not extract dimensions from $filename" >&2
    fi
' sh {} "$OUTPUT_MODE" "$CSV_FILENAME" "$BYTES_MODE"

echo ""
if [[ "$OUTPUT_MODE" == "table" ]]; then
    echo "Image metadata extraction complete."
else
    echo "CSV file saved as: $CSV_FILENAME"
fi
