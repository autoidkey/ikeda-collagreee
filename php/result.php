<?php
	//データベースとの接続の準備
	$svr = "127.0.0.1";
	$dbname = "incentive_experimentation";
	$user = "root";
	$passwd = "01xcdusd";

	$conn = mysql_connect($svr, $user, $passwd);
	if (!$conn) {
	  die('接続失敗です。'.mysql_error());
	}
	//print('<p>接続に成功しました。</p>');
	mysql_select_db($dbname) or dir("Connection Error!!");
	mysql_query('SET NAMES utf8',$conn) or die("文字コードエラー");
	echo "接続成功";

	// 投稿内容を引っ張ってくる
	$entry_sql = "select id, body from entries where theme_id = 3;";
	$entry_res = mysql_query($entry_sql, $conn) or die("Data Retrieval Error!");

	// キーワードを引っ張ってくる
	$keyword_sql = "select word from keywords where theme_id = 3;";
	$keyword_res = mysql_query($keyword_sql, $conn) or die("Data Retrieval Error!");

	// 投稿内容を表示
	while ($entry_row = mysql_fetch_array($entry_res, MYSQL_ASSOC)) {
		echo $entry_row["id"] . "\n";
		echo $entry_row["body"] . "\n";
		echo "--------------------------------------------------------\n";
	}

	// キーワードを表示
	echo "キーワードは、\n";
	while ($keyword_row = mysql_fetch_array($keyword_res, MYSQL_ASSOC)) {
		echo $keyword_row["word"] . ", ";
	}

	mysql_close($conn);
	echo "切断しました";
?>