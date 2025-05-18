# Python Lambda Layers Builder

[![License: MIT-0](https://img.shields.io/badge/License-MIT--0-blue.svg)](https://opensource.org/licenses/MIT-0)

A simple tool to build Python AWS Lambda Layers for multiple platforms using Docker. It supports installing dependencies from `requirements.txt` per layer, running customizable pre-package commands, and outputs zipped Lambda layers ready for deployment.

> ⚠️ **Disclaimer**: This tool is intended for personal/hobby use. Do not use it in production environments without thoroughly testing it in your target deployment setup.

## Features

- Supports multiple Python versions (configurable).  
- Build layers for multiple platforms (e.g. manylinux2014_x86_64, aarch64).  
- Runs pre-package clean-up commands to reduce package size.  
- Uses official AWS SAM Docker images for reproducible builds.  
- Easily add new layers by dropping directories with a `requirements.txt`.  

## Requirements (macOS)

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (tested on Docker 20.10.+)  
- Bash shell (default on macOS)  
- `realpath` utility (comes with macOS Catalina and later; if missing, install coreutils: `brew install coreutils`)  
- Optional: [Homebrew](https://brew.sh/) for package management  

## Getting Started

### Clone the repository

```bash
git clone https://github.com/gmusliaj/python-lambda-layers.git
cd python-lambda-layers
````

### Project structure

```
.
├── lambda_layers/
│   ├── pandas/
│   │   ├── requirements.txt
│   │   └── pre-package-commands.txt (optional)
│   ├── pyarrow/
│   │   └── requirements.txt
│   └── ...
├── built_lambda_layers/   # Output directory for zipped layers
└── build_layers.sh        # Build script
```

### Add or update a layer

* Create a new folder inside `lambda_layers/` (e.g., `my_layer/`)
* Add a `requirements.txt` listing Python packages to include
* (Optional) Add `pre-package-commands.txt` with cleaning commands (one command per line, in quotes)
* Example of `pre-package-commands.txt`:

  ```
  "rm -rf /asset-output/python/botocore", // Remove boto core (already in Lambda runtime)
  "find /asset-output/python -name '*.so' -type f -exec strip \"{}\" \\;", // Strip binaries
  ```

### Build layers locally

Run the build script, passing target platforms as arguments:

```bash
./build_layers.sh manylinux2014_x86_64 manylinux2014_aarch64
```

* This will build all layers inside `lambda_layers/`
* Output zipped layers will be saved to `built_lambda_layers/`
* Adjust Python version by editing `PYTHON_VERSION` in `build_layers.sh` if needed

### About the Docker Image

This tool uses the public AWS Lambda build images hosted by AWS in their public Elastic Container Registry (ECR), specifically images like public.ecr.aws/sam/build-python3.11. These images are provided and maintained by AWS to enable reproducible, consistent builds for Lambda functions and layers.

By relying exclusively on these official, publicly available AWS images, this project avoids any license infringement or redistribution concerns. The images are free to use under AWS terms and designed specifically for Lambda build environments.

For more details and the source code of these build images, see the official AWS SAM build images GitHub repository:
[https://github.com/aws/aws-sam-build-images](https://github.com/aws/aws-sam-build-images)

---

## 📄 Third-Party Package Licensing

This tool allows you to build Lambda layers that include open-source Python packages such as **Pandas**, **NumPy**, **PyArrow**, etc. When you distribute or publish these layers (e.g., in GitHub releases), you are also redistributing these packages.

Please note:

- All packages are included **as-is**, unmodified, directly from PyPI during the Docker-based build process.
- For example, **Pandas** is distributed under the [BSD 3-Clause License](https://github.com/pandas-dev/pandas/blob/main/LICENSE), which permits redistribution in binary form provided the license is retained.
- You are responsible for ensuring that appropriate licenses for included packages are made available in your repository or release.

📜 See [`third_party_licenses/`](third_party_licenses/) for license notices of included packages.

> When distributing a Lambda layer that includes packages like Pandas, include the original license file (e.g., `pandas/LICENSE`) in a folder like `third_party_licenses/` or mention it clearly in your release notes.

This repository does **not claim ownership or authorship** of any third-party packages bundled via the build script.

---

### Notes

* Make sure Docker Desktop is running and you have sufficient disk space.
* The build process creates a temporary Python virtual environment inside the Docker container.
* The script uses `sed` for parsing pre-package commands — tested on macOS and Linux.

---

### License

This project is released under the [MIT No Attribution License (MIT-0)](https://opensource.org/licenses/MIT-0).

```
MIT No Attribution License (MIT-0)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, without any conditions or limitations.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.
```

> ⚠️ Lambda layers built using this tool may contain third-party software with different licenses. You are responsible for complying with those licenses when redistributing the resulting ZIP files.

---

### Contributing

Feel free to open issues or submit pull requests! For major changes, please open a discussion first.

### Contact

For questions or support, open an issue or contact @gmusliaj.

Happy building! 🚀
