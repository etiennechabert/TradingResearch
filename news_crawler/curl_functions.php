<?php

function create_news_details_file(news_def &$news)
{
  $fileName = 'tmpResult'.$news->ticker.'.html';

  $link = $news->link;
  $cookie = "alpari2.txt";

  $curl = curl_init();
  curl_setopt($curl, CURLOPT_URL, $link);
  curl_setopt($curl, CURLOPT_VERBOSE, true);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36');
  curl_setopt($curl, CURLOPT_COOKIEFILE, realpath($cookie));

  $return = curl_exec($curl);
  curl_close($curl);
  $fd = fopen($fileName, 'w');
  fwrite($fd,$return);
  fclose($fd);
  get_news_details($news);
}

function get_symbol_page($link, $page=1)
{
  $cookie2 = "alpari2.txt";
  $link .= '&page_watch=' . $page;
  if (file_exists(realpath($cookie2)) == false)
    {
      alpari_tools();
      get_trading_central();
      get_symbol_page($link, $page);
      return ;
    }

  $curl = curl_init();
  curl_setopt($curl, CURLOPT_URL, $link);
  curl_setopt($curl, CURLOPT_VERBOSE, true);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36');
  curl_setopt($curl, CURLOPT_COOKIEFILE, realpath($cookie2));
  $return = curl_exec($curl);
  $status = curl_getinfo($curl,CURLINFO_HTTP_CODE);
  curl_close($curl);
  if ($status == 302 || $status == 301)
    {
      unlink('alpari2.txt');
      get_news_page();
      return ;
    }
  $fd = fopen('tmpResult.html', 'w');
  fwrite($fd,$return);
  fclose($fd);
}

function get_news_page($page=1)
{
  $link = "https://alpari-uk.tradingcentral.com/index.asp?p=devises&page_watch=".$page;
  $cookie2 = "alpari2.txt";
  if (file_exists(realpath($cookie2)) == false)
    {
      alpari_tools();
      get_trading_central();
      get_news_page();
      return ;
    }

  $curl = curl_init();
  curl_setopt($curl, CURLOPT_URL, $link);
  curl_setopt($curl, CURLOPT_VERBOSE, true);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36');
  curl_setopt($curl, CURLOPT_COOKIEFILE, realpath($cookie2));
  $return = curl_exec($curl);
  $status = curl_getinfo($curl,CURLINFO_HTTP_CODE);
  curl_close($curl);
  if ($status == 302 || $status == 301)
    {
      unlink('alpari2.txt');
      get_news_page();
      return ;
    }
  $fd = fopen('tmpResult.html', 'w');
  fwrite($fd,$return);
  fclose($fd);
}

function get_trading_central()
{
  $link = get_link_from_js();
  $cookie2 = "alpari2.txt";
  if (file_exists(realpath($cookie2)) == false)
    touch($cookie2);

  $curl = curl_init();
  curl_setopt($curl, CURLOPT_URL, $link);
  curl_setopt($curl, CURLOPT_VERBOSE, true);
  curl_setopt($curl, CURLOPT_COOKIESESSION, true);
  curl_setopt($curl, CURLOPT_MAXREDIRS, 10);
  curl_setopt($curl, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36');
  curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_COOKIEJAR, realpath($cookie2));
  $return = curl_exec($curl);
  curl_close($curl);
  $fd = fopen('tmpResult.html', 'w');
  fwrite($fd,$return);
  fclose($fd);
}

function alpari_tools()
{
  $link = "https://www.alpari.com/en/my/Research/TradingCentral";
  $cookie = "alpari.txt";
  if (file_exists(realpath($cookie)) == false)
    alpari_login();

  $curl = curl_init();
  
  curl_setopt($curl, CURLOPT_URL, $link);
  curl_setopt($curl, CURLOPT_VERBOSE, true);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36');
  curl_setopt($curl, CURLOPT_COOKIEFILE, realpath($cookie));
  $res = curl_exec($curl);
  $status = curl_getinfo($curl,CURLINFO_HTTP_CODE);
  curl_close($curl);
  if ($status == 302)
    {
      unlink('alpari.txt');
      alpari_tools();
      return ;
    }
  $fd = fopen('alpariTools.html', 'w');
  fwrite($fd,$res);
  fclose($fd);
}

function alpari_login()
{
  global $loginData;

  $link = "https://www.alpari.com/en/my/Account/LogOn";
  $cookie = "alpari.txt";
  if (file_exists(realpath($cookie)) == false)
    touch($cookie);

  $curl = curl_init();

  curl_setopt($curl, CURLOPT_URL, $link);
  curl_setopt($curl, CURLOPT_VERBOSE, true);
  curl_setopt($curl, CURLOPT_COOKIESESSION, true);
  curl_setopt($curl, CURLOPT_POST, true);
  curl_setopt($curl, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36');
  curl_setopt($curl, CURLOPT_POSTFIELDS, $loginData);
  curl_setopt($curl, CURLOPT_COOKIEJAR, realpath($cookie));
  curl_exec($curl);
  curl_close($curl);
}
