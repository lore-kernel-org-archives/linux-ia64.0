From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 20 Feb 2002 16:09:55 +0000
Subject: Re: [Linux-ia64] CONFIG_USB_UHCI=y not possible?
Message-Id: <marc-linux-ia64-105590701905143@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905141@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John,

On Wed, Feb 20, 2002 at 09:50:38AM -0600, John Hesterberg wrote:
> When I try to change CONFIG_USB_UHCI from a module to static (=m to =y),
> I get:
> 
>     drivers/usb/usbdrv.o: In function `alloc_uhci':
>     drivers/usb/usbdrv.o(.text.init+0x7e2): relocation truncated to fit: PCREL21B uhci_pci_remove
> 
> I don't see anything obvious (to me) with the disassembly:
> 
>      7e0:   11 60 01 40 00 21       [MIB]       mov r44=r32
>      7e6:   00 00 00 02 00 00                   nop.i 0x0
>      7ec:   08 00 00 50                         br.call.sptk.many b0~0 <alloc_uhci
> 
> It's see the same problem in a different kernel, with the same code
> at a different offset (0x672).
> 
> Anyone have any idea what's going on with this?
> 
Your kernel is too big (exceed range for relocation). You have to compile some subsystems as modules.

-- 

-Stephane

