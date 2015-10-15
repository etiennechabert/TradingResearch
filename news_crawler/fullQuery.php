<?php

require_once 'loginData.php';
require_once 'curl_functions.php';
require_once 'db_functions.php';
require_once 'parsing.php';
require_once 'tools.php';
require_once 'news.php';

function try_cache($time)
{
  if ($time != 0 && apc_exists("key:".$time))
    {
      echo apc_fetch("key:".$time);
      return true;
    }
  return false;
}

function init_env($time)
{
  chdir("/home/crowler/");
  init_db();
  $symbols = find_symbols_list();
  add_debug($time);
  return $symbols;
}

function generate_output($symbols, $time)
{
  $var = "";

  foreach ($symbols as $s)
    {
      $sym = get_symbol_name($s);
      $var .= "$sym>";
      $var .= print_news($s, $time);
      $var .= "\n";
    }
  apc_add("key:".$time, $var);
  echo $var;
}

$time = isset($_GET["time"]) ? $_GET["time"] : 0;
if (try_cache($time) == true)
  return ;

$symbols = init_env($time);
generate_output($symbols, $time);
