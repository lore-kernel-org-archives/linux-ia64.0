From: awilliam@nevermor.fc.hp.com (Alex Williamson)
Date: Fri, 31 May 2002 13:34:10 +0000
Subject: Re: [Linux-ia64] IRQ problems when running McKinley Kernel on Proliant
Message-Id: <marc-linux-ia64-105590701905626@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905625@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905625@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   A McKinley flavor kernel actually uses the PCAT Compatible interrupt
flag in the MADT table to determine if a dual-8259 interrupt controller
is present.  The Itanium kernel just assumes it's there because earlier
firmware for Lion did not have the flag set correctly.  For Lion, this
was fixed in fw 99.  I don't know if the DL590/64 is a version of the
Lion or not.  You'll probably want to check if there's newer firmware
available or toggle the ifndef CONFIG_ITANIUM in arch/ia64/kernel/acpi.c
to verify this is the problem.  

	Alex

> 
> Hi,
> 
> I've been experiencing some problems with some ia64 kernels (both ones
> I've gotten in debian and those I've compiled myself) on a Compaq
> Proliant DL590/64 which I've been doing some test installing on.
> 
> The problem manifests itself with the following error output on
> boot-up
> 
> PIIX4: IDE controller on PCI bus 00 dev 39
> PCI: Found IRQ 0 for device 00:07.1
> PIIX4: chipset revision 1
> PIIX4: not 100% native mode: will probe irqs later
>     ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
> hda: IRQ probe failed (0x7ffffffe)
> keyboard: Timeout - AT keyboard not present?(ed)
> hda: IRQ probe failed (0x7ffffffe)
> hda: CD-224E, ATAPI CD/DVD-ROM drive
> hda: IRQ probe failed (0x7ffffffe)
> hdb: IRQ probe failed (0x7ffffffe)
> hdb: IRQ probe failed (0x7ffffffe)
> hdb: LS-120 SLIM6 AG UHD Floppy, ATAPI FLOPPY drive
> hdb: IRQ probe failed (0x7ffffffe)
> ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
> hda: lost interrupt
> hda: lost interrupt
> hda: ATAPI 24X CD-ROM drive, 128kB Cache
> Uniform CD-ROM driver Revision: 3.12
> ide-floppy driver 0.97.sv
> hdb: lost interrupt
> hdb: lost interrupt
> 
> I've tried various kernel configurations with a view to isolating this
> problem, initially assuming it to be the same problem seen with
> some omnibooks where PIIXn autotuning caused lost interrupt
> problems due to various errors in drivers. After compiling a number of
> kernels, the error only occurs on the system if I compile a kernel for
> Itanium-2/McKinley rather than Itanium i.e. I can compile an Itanium
> kernel with generic pci bus-master support etc. and don't experience
> any of these problems so I assume there are some changes in the
> mckinley support which cause or reveal problems in the ide irq
> handling stuff.
> 
> Sorry for the lack of technical depth on this, I'm not sure what
> additional information may of be of use to people in resolving
> this. I'll concentrate on compiling kernels for Itanium rather than
> McKinley for now (the current debian woody images for ia64 default to
> using the mckinley kernel, I'll drop them a note suggesting they may
> wish to default to itanium to avoid this problem).
> 
> I've seen this on the linux 2.4.17 mckinley smp kernel as distributed
> by debian and a number of linux 2.4.18 kernels (with the
> latest ia64 patch kit) compiled by myself. I can provide further error
> output and kernel config files if they're of use to anyone.
> 
> Thanks,
> 
> -stephen
> 
> -- 
>    Stephen Mulcahy, Software Engineer, A&O - Multivendor Systems Engineering, 
>  HP Services, Hewlett-Packard Company, Ballybrit Business Park, Galway, Ireland
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


