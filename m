From: Colin Ngam <cngam@sgi.com>
Date: Tue, 08 Mar 2005 04:40:41 +0000
Subject: Re: PCI Express
Message-Id: <422D2CC8.2F56F4A3@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Nguyen, Tom L" wrote:

> On Monday, March 07, 2005 3:12 PM Jesse Barnes wrote:
>
> >On Monday, March 7, 2005 3:03 pm, Nguyen, Tom L wrote:
> >> On Monday, March 07, 2005 12:41 PM Colin Ngam wrote:
> >> > I looked at Documentation/MSI-HOWTO.txt(linux-ia64-release-2.6.11)
> and
> >> >
> >> > it mentioned that CONFIG_X86_LOCAL_APIC has to be configured.  I
> did
> >>
> >> not
> >>
> >> > find this configured on in any sample ia64 config files, but it
> does
> >> > exist in defconfig for i386.  Is this just an ia32 config option?
> >>
> >> IA64 uses SAPIC instead of IOxAPIC. SAPIC, which is somewhat similar
> to
> >> IOxAPIC, is included in IA64 kernel. MSI/MSI-X support configuration
> >> option therefore is always available in IA64.
>
> >So the MSIs are programmed to point at the processor SAPIC block?  I
> think
> >that'll work for us on Altix, but if they're pointed at an external
> Intel >(or
> >compatible) interrupt controller, we'll have to write new code for
> Altix.
>
> MSI/MSI-X message address is programmed to point at specific processor,
> not an external Intel interrupt controller, as a target.

Hi Long/All,

Thank you (all) very much for the information.

It's been a long time since we tested MSI/MSIX on our Altix boxes.  It has been
longer since I looked at the code.  It works and we are looking forward to
hooking them up with the current Infrastructure available on ia64 -
pci_enable|disable_msi().

On Altix systems, we have a set of "Interrupt Registers" in Memory Address Space
that is initialized to target specific CPUs.  The way we initialize a card's MSI
is:

1.  The Target Address is One of these "Interrupt Registers"
2.  The Data Payload is the IRQ plus some special Altix bits.

This memory write causes the "Interrupt Chipset" to generate a LINTR message to
the configured targeted cpu with the IRQ.  Ofcourse, these registers are Altix
Platform specific.  Moreover, we have chunks of these registers all over the
place.

Is there a more direct mechanism to generate an interrupt(LINTR Message) to a
Processor?  1 of the Special bits that I mentioned in Item 2 above causes our
hardware to flush all posted DMA buffers before allowing the LINTR Message to be
generated to the cpu.

With Altix, it's always interesting, with respect to "just work" with typical
ia64 code base.  Hopefully, it will work cleaner compared to some of our other
efforts.

Are you the maintainer for the MSI code?

Thanks.

colin

>
>
> Thanks,
> Long

