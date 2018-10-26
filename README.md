VeBlocks - a nerdy, MySQL-based Blockexplorer for VeChain
==================

All Tests are done on Vultr. Register if you want to and power up a VPS: https://www.vultr.com/?ref=7097618

This Script will import the VeChain Blockchain into an MySQL Database, so you can query some cool statistics.



1.)  What does this script do
------------------------
This Script is tested on Debian 9 64bit but will probably run on pretty much any Linux. 
This is just a little hacked script and probably full of inefficiancy and errors but it does the job. So please dont rely on the script!

This walkthrough will install 
 - A Vechain Mainnet-Node
 - A MySQL Database
 - Some Scripts to import the Blockchain to to MySQL Database


2.) Install all needed Software
------------------------
You can use this command to to a "1-Click-Installation". BUT this is only for testing! Doing this, will automatically import the Databasestructure from VeBlocks.sql and create a MySQL user "vechain" with password "VeChainToDaMoon". I recommend to change this. If you do, you also need to change the settings in the "VeBlocks_import.sh".


```shell
curl -sSL https://raw.githubusercontent.com/mirei83/VeBlocks/master/VeBlocks_deploy.sh | bash
```

3.) Make it AutoStart (optional)
------------------------
In Debian:
Add the following line bevor "exit 0" in /etc/rc.local
```shell
"/PATH/TO/start-vechain-thor.sh"
```

4.) Start the Thor-Node
------------------------
Start the Node and let it sync for about 1 hour (also prepare autostart if needed)
```shell
./start-vechain-thor.sh
```

4.) Import Mainnet to Database
------------------------
When the Vechainnode is synced you can start the import. The importscript will run forever as long as you dont stop it.


Start the import for Mainnet
```shell
./VeBlocks/VeBlocks_import.sh main
```

Start the import for Testnet (additional Testnet-Node needed)
```shell
./VeBlocks/VeBlocks_import.sh test
```

