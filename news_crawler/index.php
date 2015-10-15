<?php

require_once 'loginData.php';
require_once 'curl_functions.php';
require_once 'db_functions.php';
require_once 'parsing.php';
require_once 'tools.php';
require_once 'news.php';
date_default_timezone_set('Europe/London');

$page = 1;
write_stamp();
init_db();

do
  {
    get_news_page($page);
    $continue = get_news_section();
    $page += 1;
  } while ($continue == true);
