
# MineCryptoOnWifiRouter

This is a short guide that shows you how to mine DuinoCoin on a wifi router. <a  href="https://duinocoin.com">DuinoCoin</a> is a crypto that can even be mined on such low power devices.

1. Flash the router you want to use with <a  href="https://openwrt.org">OpenWRT</a> . There many guides for your specific router out there. This will void your Warranty!

If you want to buy a router in purpose, I would recommend a tplink. You can flash them very easily and they're cheap.

2. SSH into your router. Under Linux run: "ssh root@[routerip]. Under Windows use Putty. The default port 22 is fine.

3. Download the script to the router
4. `wget -c https://raw.githubusercontent.com/AzagraMac/MineCryptoOnWifiRouter/main/entware-ngu-setup.sh`

5. type: "`opkg update`", "`opkg install python3`" and "`opkg install coreutils-nohup`" to install python and nohup.

6. Now edit line 14 to your username. If you want to use LEDs of your router as a indication if there was a accepted or declined share, go to line 16 and change variable 'enableLEDNotification' from ```False``` to ```True```  and set line 17 to the first led and line 18 to the second led. They're coments. You can get the led names by visiting the openwrt webinterface and going to system -> LED-Configuration. Pick 2 that are free..

7. Now use a program like <a  href="https://winscp.net/eng/download.php">Winscp</a> to get the miner.py script onto your router. Select SCP as protocol.

8. Then go back to putty and type "`python3 miner.py`", or "`nohup python3 -u miner.py > /tmp/mnt/sda1/miner.log 2>&1 &`"

9. If everything seems to work, and the router is mining, press Ctrl + c and type "nohup python3 miner.py &". If it doesn't, open an issue.

10. That's it! Your router is now mining crypto! Happy Mining!

  
Officially tested Routers:

Model | Hashrate | Difficulty | Profit
--- | --- | --- | ---
Asus RT-AX58U | 42kH/s | 2500 | ~15-20 DUCO per day

  
How can I further develop this?
1. Create a fork
2. Change the things you want to change and make sure everything works
3. Open a pull request
