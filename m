From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Oct 2003 16:33:54 +0000
Subject: RE: 2.6.0-Test5 booting problems on Itanium-1!
Message-Id: <marc-linux-ia64-106606324104100@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106569415603393@msgid-missing>
In-Reply-To: <marc-linux-ia64-106569415603393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> AFAIK _start is the entry point to the IA64 kernel.
> I found that the kernel vmlinux-2.4.0-0.99.11smp *which_boots* without
> problems has a _start address = e000000000520000. This is 
> also stored in
> the 
> Elf header of the file as Entry Point Address. (I used readelf to
> confirm)
> 
> While the kernel which *I_am_trying_to_boot* vmlinux-2.6.0-test5 has
> a _start address = a000000100010000. And the elf header shows Entry
> Point Address
> as 0x4010000. This means that this kernel will not load 
> properly as the
> boot loader
> reads the elf file header and jumps to the Start Address (??).

The virtual mapping scheme for the kernel changed between 2.4 and 2.[56].
In 2.4 the kernel required that it be loaded at physical address just
above 64MB, and it used the 1:1 mapping of region 7 (virtual address physical address + 0xE000000000000000).  This scheme didn't support
systems that have no physical memory at 64MB (specifically SGI, but I'm
sure that others will build ccNUMA systems where the address of the
memory is a function of the node number).  So in 2.5.60(approx) a change
was made to allow the kernel to be loaded at any (suitably aligned)
physical address, and the early code at _start would map it to the
expected virtual address (which was moved to region 5 so as not to disturb
the simplicity of the region 7 mapping).

So the entry point you see in the Elf header of the 2.6 kernel is the
*physical* address (which would be overridden by the bootloader if the
kernel was loaded at some other address). The address of _start in the
symbol table is the virtual address.

There were some changes to the elilo bootloader too, but they happened
long, long before the kernel change was accepted (but if you are clinging
to a 2+ year old copy of elilo, it may be time to upgrade).

-Tony
