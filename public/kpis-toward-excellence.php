<?php
// Run 'pass cv/github-token' in the terminal and capture the output
// trim() removes the invisible newline character shell commands add at the end 
$token = trim(file_get_contents('/etc/cv-github-token'));
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

// Parsr the JSON response into a PHP array
$data = json_decode($result, true);

// Drill down to the weeks array
$weeks = $data['data']['user']['contributionsCollection']['contributionCalendar']['weeks'];

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>KPIs toward excellence</title>
  <link rel="stylesheet" href="style.css">
  <style>
    .grid { display: flex; gap: 3px; margin-top: 40px; }
    .week { display: flex; flex-direction: column; gap: 3px; }
    .day { 
      width: 14px;
      height: 14px;
      border-radius: 2px;
      background: #1a1a1a;
      position: relative;
      cursor: pointer;
    }
    .day[data-level="1"] { background: #0e4429; }
    .day[data-level="2"] { background: #006d32; }
    .day[data-level="3"] { background: #26a641; }
    .day[data-level="4"] { background: #39d353; }
    .day:hover::after {
      content: attr(data-date) ": " attr(data-count) " commits";
      position: absolute;
      top: -28px;
      left: 0;
      background: #333;
      color: #fff;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 11px;
      white-space: nowrap;
      z-index: 10;
    }
  </style>
</head>
<body>
  <nav>
    <a href="/">Home</a>
    <a href="/about.php">About</a>
    <a href="/kpis-toward-excellence.php">KPIs</a>
  </nav>
  <h1>KPIs toward excellence</h1>
  <p>Commits per day. Pulled live from GitHub.</p>
  <div class="grid">
    <?php foreach ($weeks as $week): ?>
      <div class="week">
        <?php foreach ($week['contributionDays'] as $day):
          $count = $day['contributionCount'];
          if ($count === 0) $level = 0;
          elseif ($count <= 2) $level = 1;
          elseif ($count <= 4) $level = 2;
          elseif ($count <= 6) $level = 3;
          else $level = 4;
        ?>
          <div class="day"
            data-count="<?php echo $count; ?>"
            data-date="<?php echo $day['date']; ?>"
            data-level="<?php echo $level; ?>">
          </div>
        <?php endforeach; ?>
      </div>
    <?php endforeach; ?>
  </div>
</body>
</html>
