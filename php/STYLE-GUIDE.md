# Coding Style Guide

## General Guidelines
- Write clear and concise code.
- Use meaningful variable and function names.
- Comment your code where necessary to explain complex logic.
- Keep functions and methods short and focused on a single task.
- Follow the DRY (Don't Repeat Yourself) principle.

## PHP Specific Guidelines

### Indentation
- Use 4 spaces for indentation. Do not use tabs.

### Naming Conventions
- Use camelCase for variable and function names.
- Use PascalCase for class names.
- Use UPPER_CASE for constants.

### File Structure
- One class per file.
- Name the file the same as the class name.

### PHP Tags
- Always use `<?php ?>` tags.

### Strings
- Use single quotes for simple strings.
- Use double quotes for strings that contain variables or escape sequences.

### Arrays
- Use short array syntax (`[]`) instead of `array()`.

### Control Structures
- Use braces for all control structures.
- Place the opening brace on the same line as the control structure.
- Place the closing brace on a new line.

### Example
```php
<?php

class ExampleClass
{
    const EXAMPLE_CONSTANT = 'value';

    private $exampleVariable;

    public function __construct($exampleVariable)
    {
        $this->exampleVariable = $exampleVariable;
    }

    public function exampleFunction()
    {
        if ($this->exampleVariable) {
            echo 'Example';
        } else {
            echo 'No Example';
        }
    }
}
?>
```