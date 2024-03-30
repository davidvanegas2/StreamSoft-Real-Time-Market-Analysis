# StreamSoft: Real-Time Market Analysis Repository

This repository contains the code for the Grouper Data repository. It is a monorepo that contains glue jobs, lambdas, shared packages and notebooks developed by Loka, Inc.

## Architecture
![streamsoft drawio](https://github.com/davidvanegas2/StreamSoft-Real-Time-Market-Analysis/assets/46963726/a9ba59a3-b511-4691-931c-f4ef6cbf8edd)

## Usage

To use this repository template, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/davidvanegas2/streamsoft_market_analysis.git
   ```
2. **Navigate to the root directory of the cloned repository:**
   ```bash
   cd streamsoft_market_analysis
   ```
3. Ensure you have the following prerequisites installed on your machine:
   - [Poetry](https://python-poetry.org/docs/)
   - [pyenv](https://github.com/pyenv/pyenv)
4. **Run the setup command:**

   ```bash
   make setup
   ```

   This command will initialize the repository, install the required Python version using pyenv, set up the local Python environment, verify the Python version, and install dependencies using Poetry.

5. **Run checks using pre-commit:**
   ```bash
   make check
   ```
   This command will run all checks configured with pre-commit, including linting and formatting using [ruff](https://github.com/astral-sh/ruff).
