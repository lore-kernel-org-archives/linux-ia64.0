From: Scott Rhine <rhine@rsn.hp.com>
Date: Thu, 12 Apr 2001 09:44:53 +0000
Subject: [Linux-ia64] Re: reporting portability bugs (fwd)
Message-Id: <marc-linux-ia64-105590693005395@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> >>>>> On Thu, 12 Apr 2001 9:15:11 CDT, Scott Rhine <rhine@rsn.hp.com> said:
> 
>   Scott> How do I report low level scsi drivers (like aha1542 & eata
>   Scott> isa) that won't build for ia64?
> 
> In general, you could report them to linux-ia64@linuxia64.org.
> 
> However, IIRC, both aha1542 and eata are ISA bus drivers.  DIG64 does
> not support ISA and we'll never support those drivers on IA-64.
> 
> 	--david

we should ifdef the config so that these illegal options cannot be selected
for ia64.

Network device support is also a minefield.
The hp ethernet driver HP 10/100VG PCLAN 
	Western Digital WD80
	scsi driver AHA152X/2825
all build but cause load failure.  These should be disallowed as well.
I would have mailed the changes, but a more methodical testing needed to be done
to find all the guilty parties.  Some sort of grep for isa would probably 
do the trick for the first pass.

drivers/net/net.o: In function `hp100_start_xmit':
drivers/net/net.o(.text+0x18fe2): undefined reference to `isa_memcpy_toio'
drivers/net/net.o(.text+0x19011): undefined reference to `isa_memset_io'
drivers/net/net.o: In function `hp100_rx':
drivers/net/net.o(.text+0x196b2): undefined reference to `isa_readl'
drivers/net/net.o(.text+0x198d1): undefined reference to `isa_memcpy_fromio'
drivers/net/net.o: In function `wd_get_8390_hdr':
drivers/net/net.o(.text+0x1df62): undefined reference to `isa_readl'
drivers/net/net.o: In function `wd_block_input':
drivers/net/net.o(.text+0x1e022): undefined reference to `isa_memcpy_fromio'
drivers/net/net.o(.text+0x1e052): undefined reference to `isa_memcpy_fromio'
drivers/net/net.o(.text+0x1e072): undefined reference to `isa_eth_io_copy_and_sum'
drivers/net/net.o: In function `wd_block_output':
drivers/net/net.o(.text+0x1e232): undefined reference to `isa_memcpy_toio'
drivers/net/net.o(.text+0x1e282): undefined reference to `isa_memcpy_toio'
ld: final link failed: Bad value

------------
Lastly, the default .config file that comes on the ftp site allows 
simulator code only and I have a live box.  When will this change?

