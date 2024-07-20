<?php
  include_once( 'session.php' );
?>

<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/docs/4.0/assets/img/favicons/favicon.ico">

    <title>Simsa - Promotion Test Management Software</title>

    <link rel="canonical" href="https://getbootstrap.com/docs/4.0/examples/cover/">

    <!-- Bootstrap core CSS -->
    <link href="include/bootstrap-5.3.3-dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="include/css/simsa/cover.css" rel="stylesheet">
    <style>
body {
  background-image: url( '/assets/images/2022-11-fresno-kukkiwon-seminar.jpg' );
  background-size: 100%;
  background-position-y: top;
}

.cover-container {
  max-width: 42em;
}

    </style>

    <script src="include/jquery-3.7.1/jquery.min.js"></script>
    <script src="include/popperjs-2.11.8-dist/popper.min.js"></script>
    <script src="include/bootstrap-5.3.3-dist/js/bootstrap.min.js"></script>
  </head>

  <body class="text-center">

    <div class="cover-container d-flex h-100 p-3 mx-auto flex-column">
      <?php include_once( 'components/header.php' ); ?>

      <main role="main" class="inner cover">
        <h1 class="cover-heading">Simsa 심사</h1>
        <p class="lead"><b>Simsa</b> is a Taekwondo belt promotion examination (승품단 심사) management system that follows the <a class="kkw-ref" href="#" data-toggle="tooltip" title="<i>Poom-Dan Promotion Test Examiner Course Textbook</i><br>Kukkiwon World Taekwondo Academy (June 2022)<br>ISBN 978-89-93484-43-4">Kukkiwon procedures</a> for Poom/Dan examination.</p>
        <form>
          <h3>Login</h3>
          <div class="form-group">
            <label for="email">Username</label>
            <input type="email" class="form-control" id="email" aria-describedby="emailHelp" placeholder="Enter email">
          </div>
          <div class="form-group">
            <label for="password">Password</label>
            <input type="password" class="form-control" id="password" placeholder="Password">
          </div>
          <div class="login-actions">
            <button type="submit" class="btn btn-primary">Login</button>
            <button class="btn btn-warning">Forgot Password</button>
          </div>
        </form>
      </main>

      <footer class="mastfoot mt-auto">
        <div class="inner">
          <p> &copy;<?= date( 'Y' ) ?> Mike Wong. All rights reserved.</p>
        </div>
      </footer>
    </div>

  </body>
  <script>
    $(() => {
      $('[data-toggle="tooltip"]').tooltip({ html : true })
      $( '#email' ).focus();
    })
  </script>
</html>

