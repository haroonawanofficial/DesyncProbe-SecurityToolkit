use LWP::UserAgent;
use DBI;
use HTML::Template;
use Getopt::Long;
use Net::HTTP::Methods;

# Command-line options
my $target_domain;
GetOptions("domain=s" => \$target_domain);

unless ($target_domain) {
    die("Usage: perl desync_test_tool.pl --domain example.com\n");
}

# Configure the UserAgent
my $ua = LWP::UserAgent->new;
$ua->timeout(10);

# Define database connection and create a table
my $dbfile = 'desync_test_results.db';
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "", { RaiseError => 1 });

# Create the results table if it doesn't exist
$dbh->do("CREATE TABLE IF NOT EXISTS test_results (test_case TEXT, result TEXT)");

# Define various test cases

# Test Case 1: Discrepancies in Processing
sub test_discrepancies_in_processing {
    my $request1 = HTTP::Request->new('GET', "http://$target_domain/index.php");
    $request1->header('Custom-Header' => 'Value1');

    my $request2 = HTTP::Request->new('GET', "http://$target_domain/index.php");
    $request2->header('Custom-Header' => 'Value2');

    my $response1 = $ua->request($request1);
    my $response2 = $ua->request($request2);

    my $result = ($response1->content ne $response2->content) ? "Pass" : "Fail";

    print "Test Case 1: $result - Responses differ in processing.\n";

    # Store result in the database
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Discrepancies in Processing', ?)", undef, $result);
}

# Test Case 2: Request Differences
sub test_request_differences {
    my $request1 = HTTP::Request->new('GET', "http://$target_domain/index.php");
    my $request2 = HTTP::Request->new('GET', "http://$target_domain/index.php");

    my $response1 = $ua->request($request1);
    my $response2 = $ua->request($request2);

    my $result = ($response1->content ne $response2->content) ? "Pass" : "Fail";

    print "Test Case 2: $result - Responses differ based on request differences.\n";

    # Store result in the database
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Request Differences', ?)", undef, $result);
}

# Test Case 3: Cache Poisoning
sub test_cache_poisoning {
    my $request = HTTP::Request->new('GET', "http://$target_domain/index.php");
    $request->header('Cache-Control' => 'no-cache');
    $request->content_type('text/html');
    $request->content("<script>Malicious Code</script>");

    my $response = $ua->request($request);

    my $result = ($response->content =~ /Malicious Code/) ? "Pass" : "Fail";

    print "Test Case 3: $result - Cache poisoning successful.\n";

    # Store result in the database
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Cache Poisoning', ?)", undef, $result);
}

# Test Case 4: Server Forwarding
sub test_server_forwarding {
    my $request = HTTP::Request->new('GET', "http://$target_domain/admin");
    my $response = $ua->request($request);

    my $result = ($response->code == HTTP_TEMPORARY_REDIRECT) ? "Pass" : "Fail";

    print "Test Case 4: $result - Server forwards requests.\n";

    # Store result in the database
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Server Forwarding', ?)", undef, $result);
}

# Test Case 5: Server Proxy Analysis
sub test_server_proxy_analysis {
    my $request = HTTP::Request->new('GET', "http://$target_domain/index.php");
    my $response = $ua->request($request);

    my $server = $response->header('Server');
    my $is_proxy = $server ? 1 : 0;
    my $role = $is_proxy ? "Front-end Proxy" : "Back-end Server";

    print "Test Case 5: The server is a $role.\n";

    # Store the result in the database
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Server Proxy Analysis', ?)", undef, $role);
}

# Test Case 6: Session Fixation
sub test_session_fixation {
    my $request1 = HTTP::Request->new('GET', "http://$target_domain/login.php?sessionid=123");
    my $response1 = $ua->request($request1);

    my $session_id = $response1->content =~ /SessionID: (\d+)/ ? $1 : 0;

    my $request2 = HTTP::Request->new('GET', "http://$target_domain/admin");
    $request2->header('Cookie' => "sessionid=$session_id");
    my $response2 = $ua->request($request2);

    my $result = ($response1->content eq $response2->content) ? "Fail" : "Pass";

    print "Test Case 6: $result - Session Fixation detected.\n";

    # Store result in the database
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Session Fixation', ?)", undef, $result);
}

# Test Case 7: Access Control Testing
sub test_access_control {
    # Define resource URLs for testing
    my $public_resource_url = "http://$target_domain/index.php";
    my $restricted_resource_url = "http://$target_domain/admin";

    # Test access to public resources
    my $request_public = HTTP::Request->new('GET', $public_resource_url);
    my $response_public = $ua->request($request_public);
    my $result_public = ($response_public->is_success) ? "Pass" : "Fail";

    print "Test Case 7: Access to public resource - $result_public.\n";

    # Test access to restricted resources (unauthenticated)
    my $request_restricted = HTTP::Request->new('GET', $restricted_resource_url);
    my $response_restricted = $ua->request($request_restricted);
    my $result_restricted = ($response_restricted->is_success) ? "Fail" : "Pass";

    print "Test Case 8: Unauthorized access to restricted resource - $result_restricted.\n";

    # Test access to restricted resources (authenticated)
    my $authenticated_user = "user";
    my $authenticated_password = "password";
    my $request_authenticated = HTTP::Request->new('GET', $restricted_resource_url);
    $request_authenticated->authorization_basic($authenticated_user, $authenticated_password);
    my $response_authenticated = $ua->request($request_authenticated);
    my $result_authenticated = ($response_authenticated->is_success) ? "Pass" : "Fail";

    print "Test Case 9: Authorized access to restricted resource - $result_authenticated.\n";

    # Store results in the database
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Access Control - Public Resource', ?)", undef, $result_public);
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Access Control - Unauthorized Access', ?)", undef, $result_restricted);
    $dbh->do("INSERT INTO test_results (test_case, result) VALUES ('Access Control - Authorized Access', ?)", undef, $result_authenticated);
}

# Generate an HTML report
sub generate_html_report {
    my $tmpl = HTML::Template->new(filename => 'report_template.tmpl');
    my $sth = $dbh->prepare("SELECT test_case, result FROM test_results");
    $sth->execute;
    my @results;
    while (my $row = $sth->fetchrow_hashref) {
        push @results, $row;
    }
    $tmpl->param(results => \@results);
    open(my $html_report, '>', 'desync_test_report.html') or die "Cannot open HTML report: $!";
    print $html_report $tmpl->output;
    close $html_report;
}

# Run the test cases
test_discrepancies_in_processing();
test_request_differences();
test_cache_poisoning();
test_server_forwarding();
test_server_proxy_analysis();
test_session_fixation();
test_access_control(); # New test case

# Generate an HTML report
generate_html_report();

# Clean up
$dbh->disconnect;
