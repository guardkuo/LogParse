# Agent Guidelines for IFT-Util Repository

## Repository Overview
This repository contains PowerShell scripts for analyzing support logs, particularly focused on media error detection and disk failure analysis.

Key scripts:
- `LogParse.ps1`: Main log parsing script for media error analysis
- `LogParseCfg.ps1`: Configuration file for LogParse.ps1
- `MediaErrorPattern.ps1`: Contains regex patterns for media error detection
- `searchfile.ps1`: Creates file lists for analysis
- `log.ps1`: Utility logging functions

## Execution Instructions

### Running Scripts
All scripts are PowerShell (.ps1) files and require PowerShell 7.1+:

```powershell
# To execute any script:
.\LogParse.ps1
.\searchfile.ps1
.\LogParseCfg.ps1  # Note: This is a configuration file, not executable standalone
.\MediaErrorPattern.ps1  # Pattern definitions, not standalone executable
.\log.ps1  # Utility functions
```

### Typical Workflow
1. Run `searchfile.ps1` to generate a file list for analysis
2. Modify `LogParseCfg.ps1` to configure input/output files and thresholds
3. Execute `LogParse.ps1` to perform the actual log analysis

## Build, Lint, and Test Commands

### Build Process
This repository does not have a traditional build process as it consists of PowerShell scripts that are executed directly.

### Linting
There is no formal linting setup currently. However, you can use:
- PowerShell Script Analyzer (PSScriptAnalyzer) for code quality checks
- Manual code review following the guidelines in this document

To run PSScriptAnalyzer (if installed):
```powershell
Invoke-ScriptAnalyzer -Path .\*.ps1 -Recurse
```

### Testing
Currently, this repository does not contain automated tests. For testing these scripts:

#### Manual Testing Approaches
1. Create sample log files with known patterns to verify parsing accuracy
2. Test edge cases like empty files, malformed entries, and boundary conditions
3. Verify output files contain expected data in correct format
4. Test configuration changes to ensure they affect behavior as expected

#### Suggested Test Structure (for future implementation)
If adding tests in the future, consider:
- Unit tests for individual functions using Pester (PowerShell testing framework)
- Integration tests for end-to-end script execution
- Test data should be stored in a `/testdata` or `/fixtures` directory
- Mock external dependencies when possible

## Code Style Guidelines

### File Organization
- Each PowerShell script should have a clear purpose
- Configuration values should be centralized in `.Cfg.ps1` files when applicable
- Utility functions should be placed in dedicated modules when possible
- Main scripts should start with a header comment describing purpose, version, and requirements
- Separate logical sections with `#region` and `#endregion` comments

### Naming Conventions
- Use PascalCase for function names (e.g., `Get-Drive-Failure-Event`)
- Use camelCase for variable names (e.g., `$inputFile`, `$maxBadSector`)
- Use descriptive names that clearly indicate purpose
- Prefix private/internal functions with an underscore if needed (though not strictly enforced in PowerShell)
- Constants should use PascalCase with clear, descriptive names
- Boolean variables should be prefixed with "Is", "Has", "Can", or "Should" (e.g., `$isValid`, `$hasError`)

### Function Design
- Include parameter validation at the start of functions
- Use explicit parameter types when beneficial (e.g., `[int32]`, `[string]`, `[hashtable]`)
- Return meaningful values or `$null` when appropriate
- Use `Write-Warning` for recoverable issues, `Write-Error` for critical errors
- Avoid using aliases in scripts for better readability
- Functions should do one thing and do it well
- Prefer pipeline-friendly functions that accept and return objects
- Use `CmdletBinding()` for advanced functions that need common parameters like `-Verbose`, `-Debug`

### Formatting
- Use 4 spaces for indentation (standard PowerShell convention)
- Place opening braces on the same line as the function/statement
- Use consistent spacing around operators and after commas
- Keep lines under 120 characters when possible for readability
- Use `#region` and `#endregion` for collapsible sections in large files
- Align related assignments and declarations when it improves readability
- Use vertical spacing to separate logical sections within functions

### Comments and Documentation
- Include a header comment block describing the script's purpose, version, author, and requirements
- Comment complex logic or non-obvious implementations
- Use `#Requires` statement to specify PowerShell version requirements
- Document function parameters, return values, and exceptions when appropriate
- Use comment-based help for functions when they are part of a module
- TODO comments should be formatted as: `# TODO: [description]`
- Avoid commenting obvious code; focus on why, not what

### Types and Variables
- Use strong typing for parameters and variables when it adds clarity
- Initialize variables when declaring them when possible
- Use `$null` explicitly rather than relying on uninitialized variables
- Prefer `[string]::IsNullOrEmpty()` or `[string]::IsNullOrWhiteSpace()` for string checks
- Use typed hashtables when appropriate: `[hashtable]$myHash = @{}`
- Use `[int]` for whole numbers, `[double]` or `[decimal]` for fractional numbers
- Avoid magic numbers; use named constants instead

### Error Handling
- Validate inputs early in functions
- Use try/catch blocks for operations that might fail
- Consider using `-ErrorAction` parameters appropriately
- Log errors to both console and log files when appropriate for debugging
- Use `throw` for terminating errors that should stop execution
- Use `Write-Error` for non-terminating errors that allow continuation
- Consider using trap statements for global error handling in scripts
- Always check for null values before accessing properties or methods

### Security Considerations
- Avoid hardcoding sensitive information like passwords or connection strings
- Use secure strings when handling credentials
- Be cautious with file paths and user input to prevent injection attacks
- Validate and sanitize user input before using it in file paths or commands
- Use `-LiteralPath` instead of `-Path` when dealing with user-provided paths to prevent wildcard interpretation
- Consider using `-WhatIf` and `-Confirm` parameters for functions that make changes

## Performance Considerations
- For large log files, consider streaming processing rather than loading everything into memory
- Be mindful of regex complexity in pattern matching; test patterns with sample data
- Cache frequently used values when appropriate (e.g., compiled regex patterns)
- Consider pipeline efficiency when processing large collections
- Use `-ReadCount` parameter with `Get-Content` for better performance with large files
- Avoid using `Format-*` cmdlets in pipelines as they are designed for display only
- Use `Where-Object` early in pipelines to reduce the number of objects processed downstream
- Consider using `.NET` methods directly for performance-critical string operations

## Dependencies
- PowerShell 7.1+ (specified in LogParse.ps1)
- No external module dependencies currently required
- All scripts are self-contained within this repository

## Debugging Tips
- Use `$DEBUG` and `$DEV_DEBUG` flags present in LogParse.ps1 for troubleshooting
- Consider adding `-Verbose` parameters to functions for detailed output
- Use `Write-Debug` for debug information that can be toggled
- Check log files (`LogParse.log`, `error.log`) for runtime information
- Use `Set-StrictMode -Version Latest` to catch common scripting errors
- Use `Trace-Command` for debugging parameter binding and command execution
- Consider using breakpoints in PowerShell IDEs like VS Code with PowerShell extension

## Contributing Guidelines
When making changes to this repository:
1. Always read the existing code to understand patterns and conventions
2. Make small, focused changes rather than large refactors unless necessary
3. Ensure changes don't break existing functionality
4. Update configuration files when adding new configurable options
5. Follow the existing code style and naming conventions
6. Add or update comments for any complex logic you modify
7. Test your changes thoroughly with various input scenarios