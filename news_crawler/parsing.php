<?php

require_once 'simple_html_dom.php';

function analyse_news(simple_html_dom_node &$newsNode)
{
  $var = new news_def;

  $var->ticker = substr_replace($newsNode->children[0]->nodes[0]->_[4], '', 0, 6);
  $var->time = $newsNode->children[1]->nodes[0]->_[4];

  $tmp = explode(' ', $newsNode->children[4]->children[0]->nodes[0]->_[4]);
  $var->symbol = $tmp[0];
  array_shift($tmp);
  $var->title = implode(' ', $tmp);
  if (!(stristr($var->title, 'intraday') != false && stristr($var->title, 'caution') == false))
    return NULL;
  $var->link = "https://alpari-uk.tradingcentral.com" . $newsNode->children[4]->children[0]->attr['href'];
    
  $var->weekTrend = get_trend($newsNode->children[5]->children[0]->attr['src']);
  $var->monthTrend = get_trend($newsNode->children[7]->children[0]->attr['src']);

  return $var;
}

function get_news_timestamp(simple_html_dom $html, $symbol)
{
  static $nb=0;
  $nb++;

  $tmp = $html->root->children[1]->children[1]->children[0]->children[1]->children[0]->children[1];
  $tmp = $tmp->children[0]->children[0]->children[2]->children[0]->children[0]->children[0];
  $date = $tmp->children[0]->children[0]->children[0]->children[0]->children[1]->children[0]->nodes[0]->_[4];
  $strdate = str_replace('/', '-', $date);
  $fullDate = explode(' ', $strdate);
  $date = explode('-', $fullDate[0]);
  $fullDate[0] = $date[2] . '-' . $date[0] . '-' . $date[1];

  if (stristr($strdate, "pm") != false)
    $fullDate[1].= "PM";
  else
    $fullDate[1].= "AM";

  $date = $fullDate[1] . ' ' . $fullDate[0];
date_default_timezone_set('Europe/London');
  $value = strtotime($date);

  echo "\n----------- ACTUALY PARSING NEWS $nb OF $symbol AT $date ---------------\n\n";

  return $value;
}

function get_news_details(news_def &$news)
{
  $fileName = 'tmpResult'.$news->ticker.'.html';
  $test = file_get_html($fileName);

  $news->time = get_news_timestamp($test, $news->symbol);
  $news->pivot = $tmp = floatval(explode(' ', ltrim($test->find('table[class=size1]')[1]->children[1]->children[1]->nodes[2]->_[4]))[1]);
  $var = trim(str_replace('<br>', ' ', strip_tags($test->find('table[class=size1]')[1]->children[1]->children[1], '<br>')));
  $var = preg_replace('!\s+!', ' ', $var);
  $tmp = explode(' ', $var);

  foreach($tmp as $t)
    {
      $len = strlen($t);
      if (substr($t, $len -1, 1) == '.')
	$t = substr($t, 0, $len -1);

      if (is_numeric($t) == true)
	$num[] = $t;
    }

  $news->actualTrend = $tmp[4];
  $news->pivot = $num[1];
  $news->t1 = $num[2];
  $news->t2 = $num[3];
  $news->r1 = $num[5];
  $news->r2 = $num[6];
}

function get_news_section($full = false)
{
  $test = file_get_html('tmpResult.html');
  $results = $test->find('tr[class=watch_title]');
  $continue = false || $full;
  if (count($results) == 0)
    $continue = false;
  foreach ($results as $res)
    {
      $tmp = analyse_news($res);
      if ($tmp == NULL)
	continue;
      if (is_new_news($tmp) == true)
        {
	  create_news_details_file($tmp);
	  add_news($tmp);
	  $continue = true;
        }
    }
  return $continue;
}

function get_link_from_js()
{
  $html = file_get_contents("alpariTools.html");
  $res = strstr($html, "http://alpari-uk.tradingcentral.com/");
  $cut = strpos($res, "');");
  return substr($res, 0, $cut);
}
