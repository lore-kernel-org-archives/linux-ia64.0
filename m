From: Bill Nottingham <notting@redhat.com>
Date: Thu, 09 Jan 2003 20:27:05 +0000
Subject: Re: [Linux-ia64] Re: disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805659@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805657@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805657@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Roy Dragseth (royd@cc.uit.no) said: 
> Well, it doesn't work during a normal bootup either.  If I remove the cached 
> info in /etc/dhcpc/ and reboots, the network initialization fails:
> 
> Setting network parameters:  [  OK  ]
> Bringing up interface lo:  [  OK  ]
> Bringing up interface eth2:  dhcpcd[536]: timed out waiting for a valid DHCP 
> server response
> Determining IP information for eth2... failed.
> [FAILED]
> 
> If I log in and run /etc/init.d/network start everything works ok:
> 
> root@compute-1-1 root]# /etc/init.d/network start
> Setting network parameters:  [  OK  ]
> Bringing up interface lo:  [  OK  ]
> Bringing up interface eth2:  [  OK  ]
> 
> I cannot see what it is different when init starts the network from when root 
> is doing it.

How quickly does it time out (after 30 seconds to a minute?)

Bill

