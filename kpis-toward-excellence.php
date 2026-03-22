<?php
// Run 'pass cv/github-token' in the terminal and capture the output
// trim() removes the invisible newline character shell commands add at the end 
$token = trim(file_get_contents('/etc/cv-github-token'));
error_log("TOKEN LENGTH: " . strlen($token));
error_log("TOKEN LENGTH: " . substr($token, 0, 10) . "...");

$username = 'gustavbjorelius';

// GraphQL query - we're asking GitHub for exactly the data we want
// contrubutionCalendar -> weeks -> days -> date and count
$query = '{"query":"{ user(login: \"' . $username . '\") { contributionsCollection { contributionCalendar { weeks { contributionDays { date contributionCount } } } } } }"}';

// Open a cURL connecion to GitHub's GraphQL API endpoint
$ch = curl_init('https://api.github.com/graphql');

// Don't print the response immediately - return it as a string 
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

// This is a POST request, not GET
curl_setopt($ch, CURLOPT_POST, true);

// The body of the POST - our GraphQL query
curl_setopt($ch, CURLOPT_POSTFIELDS, $query);

// HTTP headers:
// Authorizaion - proves who we are using our token
// User-Agent - GitHub rejects requests without this
// Content-Type - tells GitHub we're sending JSON
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: bearer ' . $token,
    'User-Agent: cv-kpi-page',
    'Content-Type: application/json'
]);

// Fire the request, store the response, free the memory
$result = curl_exec($ch);
curl_close($ch);
error_log("GITHUB RESPONSE: " . $result);
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>KPIs toward excellence</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <nav>
    <a href="/">Home</a>
    <a href="/about.php">About</a>
    <a href="/kpis-toward-excellence.php">KPIs</a>
  </nav>
  <h1>KPIs toward excellence</h1>
  <!-- <pre> preserves formatting so JSON is readable - just for debugging -->
  <pre><?php echo $result;  ?> </pre>
</body>
</html>
