From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 08 Mar 2005 16:45:49 +0000
Subject: Re: PCI Express
Message-Id: <200503080845.50155.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, March 7, 2005 8:40 pm, Colin Ngam wrote:
> It's been a long time since we tested MSI/MSIX on our Altix boxes.  It has
> been longer since I looked at the code.  It works and we are looking
> forward to hooking them up with the current Infrastructure available on
> ia64 - pci_enable|disable_msi().
>
> On Altix systems, we have a set of "Interrupt Registers" in Memory Address
> Space that is initialized to target specific CPUs.  The way we initialize a
> card's MSI is:
>
> 1.  The Target Address is One of these "Interrupt Registers"
> 2.  The Data Payload is the IRQ plus some special Altix bits.
>
> This memory write causes the "Interrupt Chipset" to generate a LINTR
> message to the configured targeted cpu with the IRQ.  Ofcourse, these
> registers are Altix Platform specific.  Moreover, we have chunks of these
> registers all over the place.

That's one way to do it, but is obviously very Altix specific.

> Is there a more direct mechanism to generate an interrupt(LINTR Message) to
> a Processor?  1 of the Special bits that I mentioned in Item 2 above causes
> our hardware to flush all posted DMA buffers before allowing the LINTR
> Message to be generated to the cpu.

Yes, see Grant's earlier message about the processor interrupt block.  If we 
target MSIs at that, they'll behave the same way as IPIs, which are already 
platform independent (i.e. they work on Altix, zx1, tiger, etc.) since the 
processor interrupt block is builtin to the CPU.  See Section 5.8.4 of Vol. 2 
of the Itanium Arch. Software Developer's Manual (the blue books).

Jesse
