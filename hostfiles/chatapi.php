<?php
//error_reporting(0);
//ini_set('display_errors', 0);

require_once 'config.php';

$ActionName = '';
$MessageText = '';
$NickName = '';
$Password = '';

$RoomFileName = '';
$RoomFileNameHidden = '';

if (isset($_GET['a']))
	$ActionName = trim(substr(htmlspecialchars(urldecode($_GET['a'])), 0, 120));

if (isset($_GET['r'])) {
	$RoomName = trim(substr(htmlspecialchars(urldecode($_GET['r'])), 0, 42));
	//$RoomName = iconv('CP1251', 'UTF-8', $RoomName);
	$RoomName = preg_replace('/[^ a-zа-яё\d]/ui', '', $RoomName);
	$RoomFileName = $RoomsFolder . '/' . $RoomName . '.txt';
}

if (isset($_GET['h'])) {
	$RoomName = trim(substr(htmlspecialchars(urldecode($_GET['h'])), 0, 42));
	$RoomFileNameHidden = $RoomsFolder . '/' . $RoomName . '.php';
}

if (isset($_GET['t']))
	$MessageText = trim(substr(htmlspecialchars(urldecode($_GET['t'])), 0, 120));

if (isset($_GET['n']))
	$NickName = trim(substr(htmlspecialchars(urldecode($_GET['n'])), 0, 22));

if (isset($_GET['p']))
	$Password = trim(substr(htmlspecialchars(urldecode($_GET['p'])), 0, 22));


if ($ActionName == 'rooms'){
	$RoomFiles = glob($RoomsFolder . '/*.txt');
	
	foreach ($RoomFiles as $fileinfo) {
		echo trim(substr(basename($fileinfo), 0, -4)) . "\r\n";
	}
	
	exit;
}

if ($ActionName == 'create'){
	$f = fopen($RoomFileName, "w");  // ("r" - считывать "w" - создавать "a" - добавлять к тексту)
	fwrite($f, ''); 
	fclose($f);
	exit;
}

if ($ActionName == 'hidden'){
	$f = fopen($RoomFileNameHidden, "w");  // ("r" - считывать "w" - создавать "a" - добавлять к тексту)
	fwrite($f, ''); 
	fclose($f);
	exit;
}

if ($ActionName == 'read'){
	if (file_exists($RoomFileNameHidden))
		echo file_get_contents($RoomFileNameHidden);
	exit;
}

if ($ActionName == 'reg' && $NickName != '' && $Password != ''){
	$conn = mysqli_connect($dbserver, $dbuser, $dbpassword, $main_db);
	
	$sql = 'CREATE TABLE IF NOT EXISTS Profiles(nickname text, password text)';
	mysqli_query($conn, $sql);
	
	if (!$conn)
		$conn = mysqli_connect($dbserver, $dbuser, $dbpassword, $main_db);
	
	$result = mysqli_query($conn, 'SELECT * FROM Profiles WHERE nickname="' . $NickName . '"');	
	if ($result)
		if (mysqli_num_rows($result) == 1) {
			echo 'User exists';
		} else {
			$result = mysqli_query($conn, 'INSERT INTO Profiles (nickname, password) VALUES ("' . $NickName . '", "' . $Password .'")');
			echo 'User registered';			
		}
	if ($conn)
		mysqli_close($conn);
	
	exit;
}

if ($ActionName == 'auth' and $NickName != '' and $Password != ''){
	$conn = mysqli_connect($dbserver, $dbuser, $dbpassword, $main_db);
	
	$sql = 'CREATE TABLE IF NOT EXISTS Profiles(nickname text, password text)';
	mysqli_query($conn, $sql);
	
	if (!$conn)
		$conn = mysqli_connect($dbserver, $dbuser, $dbpassword, $main_db);
	
	$result = mysqli_query($conn, 'SELECT * FROM Profiles WHERE nickname="' . $NickName . '"');	
	if ($result)
		if (mysqli_num_rows($result) == 1) {
			$f=mysqli_fetch_array($result);
			if ($f[1] == $Password)
				echo 'Password correct';
			else
				echo 'Password incorrect';
		} else {
			echo 'User not found';			
		}
	if ($conn)
		mysqli_close($conn);
	
	exit;
}

if ($RoomFileName == '')
	$RoomFileName = $RoomFileNameHidden;

if ($RoomFileName != '' and $NickName !='' and $Password != '' and $MessageText != '') {
	
	$conn = mysqli_connect($dbserver, $dbuser, $dbpassword, $main_db);
	$result = mysqli_query($conn, 'SELECT * FROM Profiles WHERE nickname="' . $NickName . '"');	
	if ($result)
		if (mysqli_num_rows($result) == 1) {
			$f=mysqli_fetch_array($result);
			if ($f[1] == $Password) {

				$SelfMsg = date("[H:i:s] ") . $NickName . ': ' . $MessageText . "\r\n";

				if (!file_exists($RoomFileName)) {
					$f = fopen($RoomFileName, "w");  // ("r" - считывать "w" - создавать "a" - добавлять к тексту)
					fwrite($f, $SelfMsg); 
					fclose($f);
					echo 'Written';
				} else {
					$file_data = $SelfMsg . file_get_contents($RoomFileName);
					file_put_contents($RoomFileName, $file_data);
					echo 'Added';
				}

			}
			else
				echo 'Password incorrect';
		} else {
			echo 'User not found';			
		}
		
	if ($conn)
		mysqli_close($conn);
}


?>