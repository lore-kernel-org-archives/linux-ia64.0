From: Bill Nottingham <notting@redhat.com>
Date: Thu, 09 Jan 2003 17:01:02 +0000
Subject: [Linux-ia64] Re: disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805657@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Roy Dragseth (Roy.Dragseth@cc.uit.no) said: 
> Further investigation shows that if I connect the Gbit interface to a 10Mbs 
> hub everything works ok, e.g. using the ksdevice=eth2 boot option works as 
> expected.
> 
> I have narrowed this down to the following problem:  When the init process 
> tries to configure the eth2 with dhcp it fail, but if I logon as root and run
> 
> /etc/init.d/network start
> 
> everything works ok.  Subsequent reboots also works ok because now the 
> information is cached in /etc/dhcpc/.  If I remove the cached info the 
> problem turn up again.

So, it works post-install, but not in the installer? Hm. The dhcp client
code is different in the two cases, but not in a way that should
significantly affect this case.

Bill

