From: Roy Dragseth <Roy.Dragseth@cc.uit.no>
Date: Thu, 09 Jan 2003 15:16:01 +0000
Subject: Re: [Linux-ia64] disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805656@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805655@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805655@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Further investigation shows that if I connect the Gbit interface to a 10Mbs 
hub everything works ok, e.g. using the ksdevice=eth2 boot option works as 
expected.

I have narrowed this down to the following problem:  When the init process 
tries to configure the eth2 with dhcp it fail, but if I logon as root and run

/etc/init.d/network start

everything works ok.  Subsequent reboots also works ok because now the 
information is cached in /etc/dhcpc/.  If I remove the cached info the 
problem turn up again.

Do anyone know what could be different between init running the network start 
and when root does it?

r.



