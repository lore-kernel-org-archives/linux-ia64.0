From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 25 Apr 2003 00:44:41 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705604@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 24 April 2003 4:37 pm, Jesse Barnes wrote:
> Bjorn, what about the patches posted in this thread?
> 
> http://marc.theaimsgroup.com/?t4359481700001&r=1&w=2
> 
> They seem to deal with the legacy resource issue quite nicely, and for
> the non-legacy case, pci_fixup should be making the
> pci_dev->resource[] arrays contain valid I/O addresss, shouldn't it?
> 
> Or do you have something else in mind?

I think we're talking about two different things.

If I understand it correctly, the reason for the patch you mentioned
is to take a device (VGA) that appears at a fixed IO port address,
and tweak the driver so it can talk to the device at a different
IO port address.

It doesn't expand the size of the IO port space, it just gives
you a hook to say "this hard-coded region of IO port space
really corresponds to this other region on my platform".

On the other hand, my patch is completely platform-specific and
allows us to address new IO port space that was previously not
accessible at all.  For example, on HP machines, the ia64 64K
"legacy IO port space" all gets routed to a single IO controller.
Here's a sample /proc/ioports:

    00000000-00000fff : PCI Bus 00:00
      00000060-0000006f : i8042
      00000500-000005ff : sym53c8xx
      00000600-000006ff : sym53c8xx
    00001000-00001fff : PCI Bus 00:04
    00002000-00003fff : PCI Bus 00:08
    00004000-00005fff : PCI Bus 00:10
    00006000-00007fff : PCI Bus 00:18
    00008000-00009fff : PCI Bus 00:20
      00008000-000080ff : sym53c8xx
      00008100-000081ff : sym53c8xx
    0000a000-0000bfff : PCI Bus 00:28
    0000c000-0000dfff : PCI Bus 00:30
    0000e000-0000ffff : PCI Bus 00:38

The above is the legacy IO port space (0-64K).  But the machine
has another IO controller with another 9 slots and another 64K
of IO port space that is currently unusable.  My patch just
makes that accessible, like this:

    01000000-01000fff : PCI Bus 00:40
      01000500-010005ff : sym53c8xx
      01000600-010006ff : sym53c8xx
    01001000-01001fff : PCI Bus 00:44
      01001000-010010ff : sym53c8xx
      01001100-010011ff : sym53c8xx
    01002000-01003fff : PCI Bus 00:48
    01004000-01005fff : PCI Bus 00:50
    01006000-01007fff : PCI Bus 00:58
    01008000-01009fff : PCI Bus 00:60
    0100a000-0100bfff : PCI Bus 00:68
    0100c000-0100dfff : PCI Bus 00:70
    0100e000-0100ffff : PCI Bus 00:78

Of course, the ports outside of the legacy 64K range aren't
usable by IA32 apps that use IN/OUT instructions, but they work
fine for the kernel and drivers.  David's book has a good
section on this, but I don't have it handy to give a specific
reference.

Bjorn


