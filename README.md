# ZSH Scripts

A collection of macOS shell scripts for file management and image optimization workflows. These scripts help automate repetitive tasks and improve productivity in file processing operations.

## 📁 Scripts Overview

### 📊 File Metadata Extractor

#### `list-files-metadata/`
- **File**: `list-files-metadata.zsh`
- **Purpose**: Extracts and displays detailed metadata from image files in a specified directory
- **Features**: 
  - Displays filename, size, dimensions, aspect ratio, PPI, file type, bit depth, and color space
  - Supports both table and CSV output formats
  - Human-readable file sizes with option for byte display
  - Processes multiple image formats (JPEG, PNG, TIFF, etc.)
  - Recursive directory scanning
- **Usage**: 
  ```bash
  ./list-files-metadata.zsh [source_folder] [-b]
  ```
  - `source_folder`: Directory to scan (defaults to script directory)
  - `-b`: Display file sizes in bytes instead of human-readable format
- **Use Case**: Analyzing image collections for quality assessment, file organization, or documentation

### 🖼️ Image Optimization

#### `optimize690max/`
- **File**: `optimize690max.zsh`
- **Purpose**: Automatically optimizes JPEG images to a maximum file size of 690KB
- **Features**:
  - Scans current directory and subdirectories for JPEG files
  - Uses `jpegoptim` to compress files exceeding 690KB
  - Preserves original files while optimizing size
  - Processes all `.jpg` and `.jpeg` files recursively
- **Requirements**: 
  - `jpegoptim` command-line tool (install via Homebrew: `brew install jpegoptim`)
- **Usage**: 
  ```bash
  cd /path/to/images
  ./optimize690max.zsh
  ```
- **Use Case**: Preparing images for web uploads, email attachments, or storage optimization

## 🚀 How to Use

### Prerequisites
- macOS with ZSH shell
- For image optimization: Install `jpegoptim` via Homebrew:
  ```bash
  brew install jpegoptim
  ```

### Running Scripts
1. **Make scripts executable** (if needed):
   ```bash
   chmod +x script-name.zsh
   ```

2. **For metadata extraction**:
   ```bash
   ./list-files-metadata.zsh /path/to/images
   ```

3. **For image optimization**:
   ```bash
   cd /path/to/images
   ./optimize690max.zsh
   ```

## 📋 Requirements

- macOS with ZSH shell
- `jpegoptim` (for image optimization scripts)
- `bc` (for floating-point calculations in metadata script)
- Standard Unix tools (`du`, `awk`, `cut`)

## 🔧 Script Details

Each script is designed to handle specific file management tasks:

- **Metadata Extraction**: Comprehensive image file analysis with detailed reporting
- **Image Optimization**: Automated compression for web and storage efficiency
- **Batch Processing**: Handle multiple files automatically
- **Flexible Output**: Support for both human-readable and machine-readable formats

## 📝 Notes

- Always backup your files before running optimization scripts
- Metadata extraction works with most common image formats
- Optimization scripts preserve original files while creating optimized versions
- Scripts are designed for macOS but may work on other Unix-like systems

## 🤝 Contributing

Feel free to modify these scripts for your specific needs. Each script is self-contained and can be customized for different workflows.

## 📄 License

These scripts are provided as-is for personal and professional use. Modify and distribute as needed for your projects.

---

*Created for streamlining file management and image processing workflows on macOS.*
