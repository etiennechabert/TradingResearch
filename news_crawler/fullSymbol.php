<?php

require_once 'loginData.php';
require_once 'curl_functions.php';
require_once 'db_functions.php';
require_once 'parsing.php';
require_once 'tools.php';
require_once 'news.php';

init_db();
$time = time();
    $sObject = find_news_by_symbol($argv[1], $time);
    $first_link = htmlspecialchars_decode($sObject->link);
    $page = 1;
    do
      {
	get_symbol_page($first_link, $page);
	$continue = get_news_section(true);
	$page += 1;
      }	while ($continue);