<?php

function write_stamp()
{
  $fd = fopen("stamp.txt", "w");
  fputs($fd, time());
  fclose($fd);
}

function get_symbol_name($symbol)
{
  $pos = strpos($symbol, '/');
  $sym = substr($symbol, 0, $pos) . substr($symbol, $pos + 1);
  return $sym;
}

function get_stamp()
{
  if (file_exists('/home/crowler/stamp.txt') == false)
    return "Never been updated";
  $fd = fopen("/home/crowler/stamp.txt", "r");
  $content = fgets($fd);
  fclose($fd);
  return "Last update " . date("l d F", $content) . " at " . date("H:i:s", $content);
}

function get_trend($var)
{
  if ($var == '/images/up_corner.gif')
    return 'up_trend';
  else if ($var == '/images/down_corner.gif')
    return 'down_trend';
  else if ($var == '/images/egal.gif')
    return 'range';
  return 'undifined';
}

function is_new_news(news_def &$news)
{
  $var = find_news($news);

  if ($var == false)
    return true;
  return false;
}
