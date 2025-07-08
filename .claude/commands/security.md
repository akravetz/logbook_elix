You are conducting a security review as a seasoned security-conscious developer. Use `git diff --name-only main...` to identify changed files in this branch, then perform a comprehensive security analysis.  Ignore unit test/integration test files.
Review Focus Areas
1. Authentication & Authorization

Verify proper authentication mechanisms
Check for authorization bypasses or privilege escalation
Review session management and token handling
Identify missing access controls

2. Input Validation & Sanitization

Check for SQL injection vulnerabilities
Look for XSS (Cross-Site Scripting) opportunities
Identify command injection risks
Review file upload validation
Check for path traversal vulnerabilities

3. Data Protection

Verify sensitive data is properly encrypted
Check for hardcoded secrets, API keys, or credentials
Review data exposure in logs or error messages
Identify PII handling issues

4. Infrastructure & Configuration

Check for insecure default configurations
Review dependency vulnerabilities
Identify exposed debugging endpoints
Check for insecure communication protocols

5. Business Logic

Look for race conditions
Check for logic flaws that could be exploited
Review state management issues
Identify workflow bypasses

Analysis Instructions

Examine each changed file for the security issues listed above
Trace data flow for user inputs through the application
Consider attack vectors that could exploit the changes
Review surrounding context - security issues often span multiple files

Vulnerability Classification
CRITICAL

Remote code execution
Authentication bypass
Privilege escalation to admin/root
Direct database access without authorization
Exposure of highly sensitive data (credentials, PII)

HIGH

SQL injection with data access
XSS that could steal sensitive information
File upload leading to code execution
Significant authorization flaws
Cryptographic implementation errors

MEDIUM

Information disclosure of non-sensitive data
CSRF vulnerabilities
Weak session management
Input validation bypasses with limited impact
Insecure direct object references

Output Format
For each vulnerability found, provide:
[SEVERITY] - [Vulnerability Type]

File: path/to/file.ext:line_number
Issue: Brief description of the vulnerability
Impact: What an attacker could achieve
Code: Relevant code snippet
Fix: Specific remediation steps

Additional Context Questions
Before starting the review, consider:

What is the application's threat model?
Are there any recent security incidents or known attack patterns relevant to this codebase?
What sensitive data or critical operations does this application handle?