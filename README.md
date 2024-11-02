# Contextual Directory Exporter

A powerful and flexible Bash script designed to export directory structures to JSON format with detailed metadata. Ideal for developers and system administrators who need to document, analyze, or share directory structures while excluding unnecessary files or folders.

## Table of Contents

- [Contextual Directory Exporter](#contextual-directory-exporter)
  - [Table of Contents](#table-of-contents)
    - [Features](#features)
    - [Prerequisites](#prerequisites)
    - [Installing Dependencies](#installing-dependencies)
      - [Bash 5 (for macOS users)\*\*](#bash-5-for-macos-users)
      - [tree and jq](#tree-and-jq)
    - [Installation](#installation)
    - [Usage](#usage)
    - [Sample Output](#sample-output)
    - [Example Metadata Section](#example-metadata-section)
    - [License](#license)
    - [Acknowledgments](#acknowledgments)

### Features

* **Customizable Exclusions**: Easily exclude specific directories (e.g., node_modules, .git, dist) from the export.
* **Metadata Enrichment**: Generates metadata including:
* Generation timestamp with timezone and milliseconds.
* Source and target directories.
* Output filename.
* Skipped directories with counts of skipped files.
* **Interactive Prompts**: Minimal GUI-like interaction in the terminal for user-friendly operation.
* **Detailed Logging and Error Handling**: Provides informative messages and handles errors gracefully.
* **Cross-Platform Compatibility**: Works on Unix-like systems (macOS, Linux) with Bash 4.0+.

### Prerequisites

* **Bash**: Version 4.0 or higher.
* *Note*: macOS users may need to install Bash 5 since the default Bash version is 3.x.
* **tree**: Utility for generating directory trees.
* **jq**: Command-line JSON processor.

### Installing Dependencies

#### Bash 5 (for macOS users)**

Install via Homebrew:

brew install bash

Verify installation:

bash --version

Ensure that Bash 5 is used when running the script:

/usr/local/bin/bash script.sh

#### tree and jq

Install via Homebrew:

brew install tree jq

Verify installations:

tree --version
jq --version

### Installation

 1. **Clone the Repository**

git clone <https://github.com/omarsx/contextual-directory-exporter.git>
cd contextual-directory-exporter

 2. **Make the Script Executable**

chmod +x script.sh

### Usage

 1. **Run the Script**

* If Bash 5 is not your default shell, run:

/usr/local/bin/bash script.sh

* If Bash 5 is your default shell, run:

./script.sh

 2. **Follow the Interactive Prompts**

* **Enter the source directory**: Provide the full path to the directory you want to export.
* **Enter the target directory for the export**: Provide the full path where you want the JSON output file to be saved.
* If the target directory does not exist, you will be prompted to create it.

 3. **Script Execution**

* The script will generate the directory structure, analyze skipped directories, and combine data into a final JSON file.
* Upon success, you will see a message:

✅ Success! This script was developed by <https://github.com/omarsx>. Please consider a star!

 4. **View the Output**

* Navigate to the target directory you specified.
* The output JSON file will be named in the format:

directory_export_<Month>_<Day>__<Hour>-<Minute>-<AM/PM>_PKT.json

Example:

directory_export_Nov_03__02-14-AM_PKT.json

### Sample Output

The generated JSON file includes:

* **directory_structure**: The hierarchical structure of your directory, excluding specified folders.
* **metadata**: An object containing:
* **generation_timestamp**: Exact date-time of generation in ISO 8601 format with milliseconds and UTC timezone.
* **source_directory**: The source directory path.
* **target_directory**: The target directory path.
* **output_filename**: The name of the output JSON file.
* **skipped_directories**: An array of objects, each containing:
* **name**: Name of the skipped directory.
* **skipped_file_count**: Number of files skipped within that directory.

### Example Metadata Section

"metadata": {
  "generation_timestamp": "2024-11-02T21:14:28.300Z",
  "source_directory": "/Users/omar/Projects/my_project",
  "target_directory": "/Users/omar/Desktop/directory_exports",
  "output_filename": "directory_export_Nov_03__02-14-AM_PKT.json",
  "skipped_directories": [
    {
      "name": "node_modules",
      "skipped_file_count": 12345
    },
    {
      "name": ".git",
      "skipped_file_count": 250
    }
  ]
}

### License

This project is licensed under the [MIT License](LICENSE).

### Acknowledgments

* **Author**: Developed by [Omar](https://github.com/omarsx). If you find this project helpful, please consider giving it a star on GitHub!
* **Contributors**: Contributions are welcome! Please feel free to submit issues or pull requests.
* **Inspiration**: This script was inspired by the need for a flexible and detailed directory exporting tool that can handle complex projects with ease.
