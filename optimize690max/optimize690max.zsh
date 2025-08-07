#!/bin/zsh

# Set the maximum file size in kilobytes (690KB in this case)
max_size_kb=690

# Find all JPEG files in the current directory and its subdirectories
for file in **/*.(jpg|jpeg)(.N); do
    # Get the current file size in kilobytes
    file_size_kb=$(du -k $file | awk '{print $1}')

    if [[ $file_size_kb -gt $max_size_kb ]]; then
        echo "Optimizing $file"
        jpegoptim --size=$max_size_kb $file
    fi
done

echo "Optimization complete."