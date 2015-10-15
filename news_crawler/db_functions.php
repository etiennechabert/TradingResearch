<?php

$debug = false;

function init_db()
{
  global $pdo_object;

  $pdo_object = new PDO('mysql:host=localhost;dbname=crowler', 'crowler', '');
}

function add_debug($timestamp)
{
  global $pdo_object;
  global $debug;

  if ($debug == false)
    return ;

  $time = time();
  $query = "SELECT * FROM debug AS d WHERE d.raw = '" . date('Y-m-d H:i:s', $timestamp) . "' AND d.request_date = '" . date('Y-m-d H:i:s', $time) . "'";
  $statement = $pdo_object->query($query)->fetchAll();

  if (sizeof($statement) != 0)
    return ;
  
  $query = "INSERT INTO debug (request_date, timestamp, raw, source) VALUES (";
  $query .= "'" . date('Y-m-d H:i:s', $time) . "',";
  $query .= "'" . date('Y-m-d H:i:s',$timestamp) . "',";
  $query .= "'" . date('Y-m-d H:i:s',$timestamp) . "',";
  $query .= "'$timestamp');";
  $pdo_object->query($query);
}

function add_news(news_def $news)
{
  global $pdo_object;

  $query = "INSERT INTO news (link,serial,symbol,time) VALUES (" . "'".htmlspecialchars($news->link). "', '".serialize($news)."', '" . htmlspecialchars($news->symbol) . "', '" . $news->time . "');";

  $pdo_object->query($query);
}

function find_news(news_def &$news)
{
  global $pdo_object;

  $query = 'SELECT * FROM news AS n WHERE n.link = \''.htmlspecialchars($news->link). '\' LIMIT 1';
  $statement = $pdo_object->query($query);

  $statement = $statement->fetch(PDO::FETCH_ASSOC);

  if ($statement == false)
    return NULL;

  return $statement;
}

function find_news_by_symbol($symbol, $timestamp)
{
  global $pdo_object;

  if (strstr($symbol, '/') == false)
    $symbol = substr($symbol,0,3) . '/' . substr($symbol,3,3);
  $query = "SELECT * FROM news WHERE symbol = '" . htmlspecialchars($symbol) . "' AND time <= " . $timestamp . " ORDER BY time DESC LIMIT 1";
  $res = $pdo_object->query($query)->fetch(PDO::FETCH_ASSOC);
  if ($res == false)
    return NULL;
  $var = unserialize($res['serial']);
  return $var;
}

function find_symbols_list()
{
  global $pdo_object;
  
  $query = "SELECT DISTINCT symbol FROM news";
  $res = $pdo_object->query($query)->fetchAll();
  foreach($res as $n)
    $array[] = $n["symbol"];
  return $array;
}