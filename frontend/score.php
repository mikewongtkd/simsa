<?php
  include_once( 'session.php' );
  $config = [ 'area' => 'poomsae', 'n' => 5, 'uuids' => []];
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

    <script src="include/jquery-3.7.1/jquery.min.js"></script>
    <script src="include/popperjs-2.11.8-dist/popper.min.js"></script>
    <script src="include/bootstrap-5.3.3-dist/js/bootstrap.min.js"></script>
    <script src="include/raphael-2.3.0-dist/raphael.min.js"></script>
    <style>
#examinees-selector {
  width: 100%;
  height: 100%;
  background-color: rgba( 0, 0, 0, 0.90 );
  border-radius: 1em;
}
    </style>
  </head>

  <body class="text-center">

    <div class="cover-container d-flex h-100 w-100 p-3 mx-auto flex-column">
      <?php include_once( 'components/header.php' ); ?>

      <main role="main" class="inner cover">
        <svg class="examinees" id="examinees-selector"></svg>
      </main>

    </div>

  </body>
  <script>
let canvas = Raphael( $( '#examinees-selector' ));
  </script>
</html>

