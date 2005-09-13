From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 Sep 2005 06:17:33 +0000
Subject: Re: 2.6.14-rc1 breaks tg3 on ia64
Message-Id: <23056.1126592253@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Mon, 12 Sep 2005 22:37:55 MST."
             <20050912.223755.56102921.davem@davemloft.net> 
References: <22029.1126588937@kao2.melbourne.sgi.com>
In-Reply-To: <22029.1126588937@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "David S. Miller" <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, 12 Sep 2005 22:37:55 -0700 (PDT),=20
"David S. Miller" <davem@davemloft.net> wrote:
>From: Keith Owens <kaos@sgi.com>
>Date: Tue, 13 Sep 2005 15:22:17 +1000
>
>> 2.6.14-rc1 + kdb on ia64 (SGI Altix).
>>=20
>> tg3.c:v3.39 (September 5, 2005)
>> ACPI: PCI Interrupt 0001:01:04.0[A]: no GSI
>> BRIDGE ERR_STATUS 0x800
>> BRIDGE ERR_STATUS 0x800
>> PCI BRIDGE ERROR: int_status is 0x800 for 011c32:slab0:widget15:bus0
>>     Dumping relevant 011c32:slab0:widget15:bus0 registers for each bit s=
et...
>>         11: PCI bus device select timeout
>>             PCI Error Address Register: 0x3000000316808
>>             PCI Error Address: 0x316808
>>     PIC Multiple Interrupt Register is 0x800
>>         11: PCI bus device select timeout
>>=20
>> Followed by a machine check and reboot :(  2.6.13 worked fine.  Any
>> ideas which patch to backout this time?
>
>Does copying over the 2.6.13 tg3.[ch] driver over into your
>2.6.14-rc1 tree make it work?

No, the 2.6.13 driver in 2.6.14-rc1 has exactly the same problem.

The last time that tg3 broke like this, it was because of the patch
below, in 2.6.13-rc6.  That was backed out in 2.6.13-rc7.  Was the PCI
patch (or equivalent) reinstated in 2.6.14-rc1?

From: John W. Linville <linville@tuxdriver.com>
Date: Fri, 5 Aug 2005 01:06:10 +0000 (-0700)
Subject: [PATCH] PCI: restore BAR values after D3hot->D0 for devices that n=
eed it
X-Git-Tag: v2.6.13-rc6
X-Git-Url: http://kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.6.g=
it;a=3Dcommitdiff;h=FEc59a711eef002d4ef9eb8de09dd0a26986eb77

