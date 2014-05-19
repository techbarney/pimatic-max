<?php
error_reporting(0);
// use static values for testing... TODO: Remove once everything is working
//$host = "192.168.0.59"; // Your Cube-IP or hostame Here!
//$port = "62910"; // Cube Port
//$RoomID = "1"; // RoomID (check with scan.php)
//$DeviceRF = "085e4c"; // DeviceRF (check with scan.php)
//$temp = $_GET["temp"];
//$mode = $_GET["mode"];
//$type = $RoomID = $argv[3];
$host = $argv[1];
$port = $argv[2];
include('read.php'); // include the variables
$RoomID = $argv[3];
$DeviceRF = $argv[4];
$type = $argv[5];
$temp = $argv[6]; if($temp == "x") { $temp = $deviceconf[$DeviceRF]["Temperature"]; }
$mode = $argv[7]; if($mode == "") { $mode = $deviceconf[$DeviceRF]["Mode"]; }
//get data from the cube
if ($data && $deviceconf)
{
$handle = fopen('data/'.$host.'.txt','w');
fputs($handle,serialize($data));
fclose($handle);
$handle = fopen('data/'.$host.'_dev.txt','w');
fputs($handle,serialize($deviceconf));
fclose($handle);
}
else
{
$data = unserialize(file_get_contents('data/'.$host.'.txt'));
$deviceconf = unserialize(file_get_contents('data/'.$host.'_dev.txt'));
}


// only status call
if($type == "status") {
	$status = array('actTemp' => $deviceconf[$DeviceRF]["Temperature"], 'mode' => $deviceconf[$DeviceRF]["Mode"], 'comfyTemp' => $deviceconf[$DeviceRF]["ComfortTemperature"], 'ecoTemp' => $deviceconf[$DeviceRF]["EcoTemperature"]);
   echo json_encode($status);
   exit();
   }
// check if max.php is here
elseif($type == "check") { echo "found"; exit(); }

$cmd_log = "Host: ".$host." Port: ".$port." RoomID: ".$RoomID." Device: ".$DeviceRF." Type: ".$type." temp: ".$temp." mode: ".$mode;
echo $cmd_log;


// converting the send string into base64
function hex_to_base64($hex){
  $return = '';
  foreach(str_split($hex, 2) as $pair){
    $return .= chr(hexdec($pair));
  }
  return base64_encode($return);
}  

$fp = @fsockopen($host, $port, $errno, $errstr, 5);
$finished = 0;
$jetzt = time();
$buff = "";
while (!feof($fp) && time() < $jetzt+20 && $finished == 0)
{
  $line = fgets($fp);
  if (strpos($line,"L:") !== false) $finished = 1;
  if ($line != "")  $buff .= $line."\n";
}


$command = "00 04 40 00 00 00 00 FE 30 01 A8 8B 8B 1F";

// Filter empty ones and replace them with the known values
if ($mode != "") { } else { $mode = $deviceconf[$DeviceRF]["Mode"]; }
if ($temp != "") { } else { $temp = $deviceconf[$DeviceRF]["Temperature"]; }

switch ($mode)
{
case "auto": $mode = '00'; break;
case "manu": $mode = '01'; break;
case "boost": $mode = '11'; break;
default: $mode = '00';
}

$deg = strtoupper(dechex(bindec($mode.decbin($temp*2))));
$command = "00 04 40 00 00 00 ".strtoupper($DeviceRF)." 01 ".$deg."";
$send = "s:".hex_to_base64(str_replace(" ","",$command))."\r\n";


fputs($fp,$send);
$finished = 0;
$jetzt = time();
$buff = "";
while (!feof($fp) && time() < $jetzt+20 && $finished == 0)
{
  $line = fgets($fp);
  if (strpos($line,"S:") !== false) $finished = 1;
  if ($line != "")  $buff .= $line."\n";

}
//$return = '<hr /><pre>'.print_r($buff,true).'</pre>';


fclose($fp);

$logfile = fopen("logfile.log", "a"); // wird die Logdatei geöffnet
    $error = date("d.m.Y H:i:s")." - ".$cmd_log." \r\n"; // und die Fehlermeldung (inkl. Datum/Uhrzeit und dem Query)
    fwrite($logfile, $error); // in die Logdatei geschrieben
    fclose($logfile); // und zum Schluss wird die Logdatei wieder geschlossen
//echo $return."<br>";
//echo $temp." temp<br>";
//echo $mode." mode<br>";
//echo $deg." deg<br>";

?>