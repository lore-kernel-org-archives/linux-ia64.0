From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 12 May 2003 20:58:41 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 09 May 2003 5:20 pm, David Mosberger wrote:
> I'm suspecting this patch may be causing me some grief on a Big Sur.
> What happens is that the qla1280 is configured to use I/O space by
> default (no idea why that is the case, apart from a small buglet in
> reading the base address) and with the patch applied, it fails to get
> the range from 0x2000-0x20ff.
> ...
> $ cat /proc/ioports
> 00000000-000003af : PCI Bus 00:00
>   00000060-0000006f : i8042
>   00000170-00000177 : ide1
>   000001f0-000001f7 : ide0
>   00000376-00000376 : ide1
> 000003c0-000003df : vga+
> 000003e0-00000cf7 : PCI Bus 00:00
>   000003f6-000003f6 : ide0
>   000003f8-000003ff : serial
> 00000d00-00000fff : PCI Bus 00:00
> 00001000-00001fff : PCI Bus 00:00
>   00001000-0000103f : eepro100
>   00001040-0000105f : uhci-hcd
> 00002000-00002000 : PCI Bus 00:01
> 00003000-0000ffff : PCI Bus 00:03
> 
> Perhaps the problem is that the reported range for Bus 00:01 is empty?
> Does this make any sense to you?  Perhaps it's a firmware problem.

I think this is a firmware problem.  On my box, the range for
Bus 00:01 is more sensible (0x2000-0x2fff), but there are several
other oddities:

	- IO space 0x0-0x0 reported for 00:01 and 00:02
	- mem space 0x0-0x0 reported for 00:01 and 00:02
	- IO space 0x3000-0x3000 reported for 00:02
	- mem space 0xa0000-0xfffff reported for both 00:00 and 00:03
	- IO space 0x3b0-0x3df reported for both 00:00 and 00:03

We could ignore the zero-length regions, which would kill a few warnings,
but the latter two (regions reported for two buses) just seem completely
broken.  And I think I'd rather just leave the warnings as aids to
finding firmware defects.

We will probably always get the warning about ports 0x3b0-0x3df
already being allocated, because the VGA ports are reserved long
before the root bridges are enumerated.

Bjorn


