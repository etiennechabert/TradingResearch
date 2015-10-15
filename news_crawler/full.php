<?php

require_once 'loginData.php';
require_once 'curl_functions.php';
require_once 'db_functions.php';
require_once 'parsing.php';
require_once 'tools.php';
require_once 'news.php';

init_db();
$symbols = find_symbols_list();
$time = time();
foreach ($symbols as $s)
  {
    shell_exec("php fullSymbol.php $s > /dev/null 2> /dev/null &");
  }

