From: "David S. Miller" <davem@davemloft.net>
Date: Tue, 13 Sep 2005 05:37:55 +0000
Subject: Re: 2.6.14-rc1 breaks tg3 on ia64
Message-Id: <20050912.223755.56102921.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <22029.1126588937@kao2.melbourne.sgi.com>
In-Reply-To: <22029.1126588937@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kaos@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 Sep 2005 15:22:17 +1000

> 2.6.14-rc1 + kdb on ia64 (SGI Altix).
> 
> tg3.c:v3.39 (September 5, 2005)
> ACPI: PCI Interrupt 0001:01:04.0[A]: no GSI
> BRIDGE ERR_STATUS 0x800
> BRIDGE ERR_STATUS 0x800
> PCI BRIDGE ERROR: int_status is 0x800 for 011c32:slab0:widget15:bus0
>     Dumping relevant 011c32:slab0:widget15:bus0 registers for each bit set...
>         11: PCI bus device select timeout
>             PCI Error Address Register: 0x3000000316808
>             PCI Error Address: 0x316808
>     PIC Multiple Interrupt Register is 0x800
>         11: PCI bus device select timeout
> 
> Followed by a machine check and reboot :(  2.6.13 worked fine.  Any
> ideas which patch to backout this time?

Does copying over the 2.6.13 tg3.[ch] driver over into your
2.6.14-rc1 tree make it work?
