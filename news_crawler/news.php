<?php

class news_def
{
    public $ticker;
    public $time;
    public $symbol;
    public $title;
    public $link;
    public $actualTrend;
    public $weekTrend;
    public $monthTrend;
    public $t1;
    public $t2;
    public $pivot;
    public $price;
    public $r1;
}

function log_news_query($symbol, $timeRequest)
{
  $symbol = get_symbol_name($symbol);  
  $currentTime = time();

  $fd = fopen("./logs" . $symbol, "a+");
  $ret = fwrite($fd, date("H:i:s m.d.y",$currentTime) . " $symbol at " . date("H:i:s m.d.y", $timeRequest) . "\n");
  fclose($fd);
}

function print_news($symbol="EURUSD", $time=0)
{
  $date = new DateTimeZone('Europe/London');
  $date2 = new DateTime('now', $date);
  $timestamp = $date2->getTimeStamp();
  if ($time == 0)
    $time = $timestamp;
  $result = find_news_by_symbol($symbol, $time);
  $var = "";
  if ($result == NULL)
    echo "null";
  else
    {
      $var .= "symbol:" . $result->symbol . ";";
      $var .= "actualTrend:" . $result->actualTrend . ";";
      $var.= "weekTrend:" . $result->weekTrend . ";";
      $var.= "monthTrend:" . $result->monthTrend . ";";
      $var.= "target1:" . $result->t1 . ";";
      $var.= "target2:" . $result->t2 . ";";
      $var.= "pivot:" . $result->pivot . ";";
      $var.= "resistance1:" . $result->r1 . ";";
      $var.= "time:" . $result->time . ";";
    }
  return $var;
}