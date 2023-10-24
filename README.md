# DesyncProbe
Advanced HTTP desync testing tool with robust error handling, multithreading, and comprehensive reporting for security assessment.

# DesyncProbe: Advanced HTTP Desync Testing Tool

## Overview

DesyncProbe is a powerful and advanced tool designed for assessing HTTP desync vulnerabilities in web servers. It combines robust error handling, multithreading, and detailed reporting for comprehensive security assessment, with the added benefit of SQLite database integration.

## Key Benefits

- **Comprehensive Testing:** Identify discrepancies in processing, request differences, cache poisoning, session fixation, access control issues, and more.

- **Robust Error Handling:** Exception handling ensures the tool continues running in the presence of issues.

- **Multithreading:** Concurrent execution of test cases for improved speed and efficiency.

- **SQLite Database Integration:** Store test results in an SQLite database, enabling better data management and historical tracking of security assessments.

- **Detailed Reporting:** Generate HTML reports with extensive information about test case results, execution details, and historical data.

- **Vulnerability Assessment:** Discover security vulnerabilities and assess the server's handling of authenticated requests.

## Performance

DesyncProbe's use of multithreading and efficient error handling enhances speed and performance. It can quickly assess servers for desync vulnerabilities, making it a valuable addition to your security testing toolkit.

## Use Cases

- **Security Testing:** Perform comprehensive security assessments to uncover vulnerabilities in web servers.

- **Web Application Penetration Testing:** Use DesyncProbe to identify and address HTTP desync issues during penetration tests.

- **Continuous Monitoring:** Incorporate the tool into your security monitoring processes for ongoing protection against desync attacks.

## Reporting Power

DesyncProbe offers advanced reporting capabilities with the following features:

- **SQLite Database:** Store results in an SQLite database for structured data management and historical tracking.

- **HTML Reports:** Generate detailed HTML reports, including test case results, execution details, and historical data.

- **Customization:** Tailor reports to match your specific reporting requirements and corporate branding.

- **Data Visualization:** Use historical data to create charts and graphs for trend analysis and vulnerability assessment.

## Usage

1. Clone this repository.
2. Install the required Perl modules using `cpan` or `cpanm`.
3. Run DesyncProbe with your target domain: `perl desync_probe.pl --domain example.com`.

## License

This tool is released under the [MIT License](LICENSE).

Feel free to contribute, report issues, and improve DesyncProbe. We welcome your feedback and contributions.
