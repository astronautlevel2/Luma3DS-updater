<?php
echo "StarUpdater Script Refresher";
//Download the latest script
file_put_contents("index-nightly-n.lua", file_get_contents("https://github.com/gnmmarechal/StarUpdater/raw/master/index-server.lua"));
//Check MD5 hash against current script hash
$currentmd5 = md5_file("index-nightly.lua");
$newmd5 = md5_file("index-nightly-n.lua");
if ($currentmd5 == $newmd5)
{
	//Deletes the script downloaded if hash is the same
	unlink("index-nightly-n.lua");
}
else
{
	//Delete the current script and replace it with the new one
	unlink("index-nightly.lua");
	rename("index-nightly-n.lua", "index-nightly.lua");
}
?>
