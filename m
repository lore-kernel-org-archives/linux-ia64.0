From: Roy Dragseth <royd@cc.uit.no>
Date: Thu, 09 Jan 2003 20:16:59 +0000
Subject: Re: [Linux-ia64] Re: disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805658@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805657@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805657@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thursday 09 January 2003 18:01, Bill Nottingham wrote:
> So, it works post-install, but not in the installer? Hm. The dhcp client
> code is different in the two cases, but not in a way that should
> significantly affect this case.

Well, it doesn't work during a normal bootup either.  If I remove the cache=
d=20
info in /etc/dhcpc/ and reboots, the network initialization fails:

Setting network parameters:  [  OK  ]
Bringing up interface lo:  [  OK  ]
Bringing up interface eth2:  dhcpcd[536]: timed out waiting for a valid DHC=
P=20
server response
Determining IP information for eth2... failed.
[FAILED]

If I log in and run /etc/init.d/network start everything works ok:

root@compute-1-1 root]# /etc/init.d/network start
Setting network parameters:  [  OK  ]
Bringing up interface lo:  [  OK  ]
Bringing up interface eth2:  [  OK  ]

I cannot see what it is different when init starts the network from when ro=
ot=20
is doing it.

r.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no


