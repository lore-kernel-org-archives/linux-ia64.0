From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 30 Sep 2005 21:20:11 +0000
Subject: Re: [PATCH] set altix preferred console
Message-Id: <200509301520.11105.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 30 September 2005 2:04 pm, Greg Edwards wrote:
> Set the preferred console on Altix, if no console=<console> was passed
> on the boot line.
> 
> Bjorn, the hunk I removed in pcdp.c broke the vga console on Altix and
> the virtual terminal if any console= was passed in.  For example, if
> you booted with console=ttySG0 (the L1 serial console), there would be
> no login prompt on tty1 when you got to multiuser, even though a getty
> was running.  Is removing this ok?

I don't think removing the pcdp.c hunk is the right fix.

The PCDP not a device discovery interface.  The OS must be able to
discover console devices some other way, and the PCDP is only a
mechanism for firmware to tell the OS which of those devices to
use.  That's why we ignore the PCDP if the user explicitly uses
"console=" -- he's saying "ignore what the firmware told you,
and use *this* device as the console."

So the intent is that pcdp.c should be completely optional, i.e.,
it basically gives you a pointer to a device that is completely
described elsewhere, either in ACPI or by standard PCI enumeration.
If you turn off "CONFIG_EFI_PCDP", everything should work (except
that now you have to use "console=" if you want something other
than the default console).

But I think that if you turn off CONFIG_EFI_PCDP, your VGA
device won't work at all, because you're relying on the PCDP
to set vga_console_{iobase,membase}, and there's currently no
other way those get set.

I think what *should* happen is that we should discover VGA
devices by PCI enumeration, and the iobase/membase information
would come from the ACPI description of the PCI root bridges.
Then we could support multiple VGA devices, and the PCDP could
point to one of them to be used as the console.

The VGA code in the kernel is a long ways from that.  But your
firmware should provide the vga_console_{iobase,membase} data
somewhere besides the PCDP.  Can you do something in ia64/sn
to dig it out?
