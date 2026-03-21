<?php $name = "Gustav Bjorelius"; ?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title><?php echo $name;?></title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <nav>
  <a href="/">Home</a>
  <a href="/about.php">About</a>
  <a href="/hell.php">Hell</a>
</nav>
  <h1><?php echo $name; ?></h1>
  <p>Developer. Builder. Work in progress.</p>
  <button id="btn">This is a button</button>
  <script src="script.js"></script>
</body>
</html>
