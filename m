From: Stephen Mulcahy <stephen.mulcahy@hp.com>
Date: Wed, 05 Jun 2002 15:47:18 +0000
Subject: Re: [Linux-ia64] IRQ problems when running McKinley Kernel on Proliant
Message-Id: <marc-linux-ia64-105590701905642@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905625@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905625@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Alex,

Thanks for your response. I've made some inquiries and this is a known
firmware issue that will be resolved in the next firmware release for
this platform, however the timeframe for this firmware release isn't
decided yet. In the meantime, people wanting to run linux on a dl590
may wish to compile an itanium-specific kernel to avoid interrupt
problems.

-stephen

On Fri, 31 May 2002, Alex Williamson wrote:

AW> 
AW> 
AW>    A McKinley flavor kernel actually uses the PCAT Compatible interrupt
AW> flag in the MADT table to determine if a dual-8259 interrupt controller
AW> is present.  The Itanium kernel just assumes it's there because earlier
AW> firmware for Lion did not have the flag set correctly.  For Lion, this
AW> was fixed in fw 99.  I don't know if the DL590/64 is a version of the
AW> Lion or not.  You'll probably want to check if there's newer firmware
AW> available or toggle the ifndef CONFIG_ITANIUM in arch/ia64/kernel/acpi.c
AW> to verify this is the problem.  
AW> 
AW> 	Alex
AW> 
AW> > 
AW> > Hi,
AW> > 
AW> > I've been experiencing some problems with some ia64 kernels (both ones
AW> > I've gotten in debian and those I've compiled myself) on a Compaq
AW> > Proliant DL590/64 which I've been doing some test installing on.
AW> > 
AW> > The problem manifests itself with the following error output on
AW> > boot-up
AW> > 
AW> > PIIX4: IDE controller on PCI bus 00 dev 39
AW> > PCI: Found IRQ 0 for device 00:07.1
AW> > PIIX4: chipset revision 1
AW> > PIIX4: not 100% native mode: will probe irqs later
AW> >     ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
AW> > hda: IRQ probe failed (0x7ffffffe)
AW> > keyboard: Timeout - AT keyboard not present?(ed)
AW> > hda: IRQ probe failed (0x7ffffffe)
AW> > hda: CD-224E, ATAPI CD/DVD-ROM drive
AW> > hda: IRQ probe failed (0x7ffffffe)
AW> > hdb: IRQ probe failed (0x7ffffffe)
AW> > hdb: IRQ probe failed (0x7ffffffe)
AW> > hdb: LS-120 SLIM6 AG UHD Floppy, ATAPI FLOPPY drive
AW> > hdb: IRQ probe failed (0x7ffffffe)
AW> > ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
AW> > hda: lost interrupt
AW> > hda: lost interrupt
AW> > hda: ATAPI 24X CD-ROM drive, 128kB Cache
AW> > Uniform CD-ROM driver Revision: 3.12
AW> > ide-floppy driver 0.97.sv
AW> > hdb: lost interrupt
AW> > hdb: lost interrupt
AW> > 
AW> > I've tried various kernel configurations with a view to isolating this
AW> > problem, initially assuming it to be the same problem seen with
AW> > some omnibooks where PIIXn autotuning caused lost interrupt
AW> > problems due to various errors in drivers. After compiling a number of
AW> > kernels, the error only occurs on the system if I compile a kernel for
AW> > Itanium-2/McKinley rather than Itanium i.e. I can compile an Itanium
AW> > kernel with generic pci bus-master support etc. and don't experience
AW> > any of these problems so I assume there are some changes in the
AW> > mckinley support which cause or reveal problems in the ide irq
AW> > handling stuff.
AW> > 
AW> > Sorry for the lack of technical depth on this, I'm not sure what
AW> > additional information may of be of use to people in resolving
AW> > this. I'll concentrate on compiling kernels for Itanium rather than
AW> > McKinley for now (the current debian woody images for ia64 default to
AW> > using the mckinley kernel, I'll drop them a note suggesting they may
AW> > wish to default to itanium to avoid this problem).
AW> > 
AW> > I've seen this on the linux 2.4.17 mckinley smp kernel as distributed
AW> > by debian and a number of linux 2.4.18 kernels (with the
AW> > latest ia64 patch kit) compiled by myself. I can provide further error
AW> > output and kernel config files if they're of use to anyone.
AW> > 
AW> > Thanks,
AW> > 
AW> > -stephen
AW> > 
AW> > -- 
AW> >    Stephen Mulcahy, Software Engineer, A&O - Multivendor Systems Engineering, 
AW> >  HP Services, Hewlett-Packard Company, Ballybrit Business Park, Galway, Ireland
AW> > 
AW> > 
AW> > _______________________________________________
AW> > Linux-IA64 mailing list
AW> > Linux-IA64@linuxia64.org
AW> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
AW> > 
AW> 

-- 
   Stephen Mulcahy, Software Engineer, A&O - Multivendor Systems Engineering, 
 HP Services, Hewlett-Packard Company, Ballybrit Business Park, Galway, Ireland
              tel: +353-91-754584 / mailto:stephen.mulcahy@hp.com


