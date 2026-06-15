# Understanding YAML Syntax and GitHub Actions Workflows

This document explains the fundamental concepts of YAML syntax, how indentation works, and how these apply to structuring GitHub Actions workflows, including jobs and steps.

## 1. YAML Syntax Fundamentals

YAML (YAML Ain't Markup Language) is a human-friendly data serialization standard for all programming languages. It's often used for configuration files due to its readability.

### Key-Value Pairs
The most basic structure in YAML is a key-value pair.

```yaml
key: value
```

The key is a string, followed by a colon and a space, then the value.

### Scalars
Values can be various types of scalars:
-   **Strings:** Can be unquoted (if they don't contain special characters) or quoted (single or double).
    ```yaml
    name: John Doe
    message: "Hello, world!"
    ```
-   **Numbers:** Integers or floats.
    ```yaml
    age: 30
    price: 19.99
    ```
-   **Booleans:** `true` or `false`.
    ```yaml
    is_active: true
    ```
-   **Null:** Represented by `null` or `~`.
    ```yaml
    optional_field: null
    ```

### Lists (Sequences)
Lists are represented by hyphens (`-`) followed by a space, with each item on a new line.

```yaml
fruits:
  - Apple
  - Banana
  - Orange
```

### Dictionaries (Mappings/Objects)
Dictionaries are collections of key-value pairs, often nested.

```yaml
person:
  name: Jane
  age: 25
  address:
    street: 123 Main St
    city: Anytown
```

### Multi-line Strings (Block Scalars)
For multi-line strings, especially shell commands, you use block scalars:
-   **Literal Block (`|`):** Preserves newlines and leading/trailing whitespace.
    ```yaml
    script: |
      echo "Line 1"
      echo "Line 2"
    ```
-   **Folded Block (`>`):** Folds newlines into spaces, making the string a single line (unless there are blank lines).
    ```yaml
    description: >
      This is a very long
      description that will
      be folded into a single line.
    ```

## 2. Indentation in YAML

Indentation is **crucial** in YAML as it defines the structure and hierarchy of the data.
-   **Significant Whitespace:** Unlike JSON or XML, YAML uses whitespace (spaces, not tabs) to denote nesting.
-   **Consistent Indentation:** All elements at the same level of a hierarchy must have the same indentation.
-   **Standard Practice:** Typically, 2 spaces are used for each level of indentation. Tabs are generally not allowed and can cause parsing errors.

Example of correct indentation:
```yaml
parent_key:
  child_key_1: value1
  child_key_2:
    grandchild_key: value2
  - list_item_1
  - list_item_2
```

## 3. GitHub Actions Workflows

GitHub Actions workflows are defined in YAML files (`.yaml` or `.yml`) within the `.github/workflows/` directory of your repository.

### Workflow Structure
A typical workflow file starts with `name` and `on` (triggers).

```yaml
name: My CI Workflow
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs: # This is where the main work happens
  # ... jobs defined here ...
```

### Jobs
A `job` is a set of `steps` that execute on the same runner. All steps in a job share the same environment and filesystem. Jobs run in parallel by default, but you can configure dependencies using `needs`.

```yaml
jobs:
  build: # This is the ID of the job
    name: Build and Test
    runs-on: ubuntu-latest # Specifies the runner environment
    steps: # List of steps for this job
      # ... steps defined here ...
  deploy:
    name: Deploy Application
    runs-on: ubuntu-latest
    needs: build # This job will only run after the 'build' job completes successfully
    steps:
      # ... steps defined here ...
```

### Steps
A `step` is an individual task within a `job`. Steps can run commands, execute scripts, or use pre-built actions. Steps are executed sequentially within a job.

```yaml
steps:
  - name: Checkout code # A descriptive name for the step
    uses: actions/checkout@v4 # Uses a pre-defined GitHub Action

  - name: Set up Node.js # Another step
    uses: actions/setup-node@v4
    with:
      node-version: '20'

  - name: Install dependencies # A step that runs a shell command
    run: npm install

  - name: Run tests
    run: | # Using a literal block scalar for multi-line commands
      npm test
      echo "Tests completed successfully!"
```

**Key points for steps:**
-   Each step starts with a hyphen (`-`) to denote it as a list item.
-   `name`: A human-readable title for the step.
-   `uses`: Specifies a GitHub Action to run (e.g., `actions/checkout@v4`).
-   `run`: Executes a shell command. For multi-line commands, use `|` (literal block scalar).
-   `with`: Provides inputs to actions (e.g., `node-version` for `setup-node`).
-   `env`: Sets environment variables for the current step.
-   `working-directory`: **Critical Best Practice:** Always specify the `working-directory` for steps involving Terraform, Docker builds, or script execution. This prevents errors when workflows navigate between different project sub-directories.

By understanding these YAML and GitHub Actions concepts, you can effectively create and manage your CI/CD workflows.