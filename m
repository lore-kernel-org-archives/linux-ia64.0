From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 29 Jun 2004 18:13:39 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406291113.39204.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, June 29, 2004 11:03 am, Chen, Kenneth W wrote:
> Jesse Barnes wrote on Tuesday, June 29, 2004 10:46 AM
>
> > > > I tried both of these on a machine that doesn't have memory at the
> > > > stock kernel load address, and it failed very early on.  However, it
> > > > works with the attached patch.
> > >
> > > Let me confirm what I understand:
> > > David's bk tree doesn't boot.
> > > David's bk tree + 2 patches I posted this morning doesn't boot.
> > >
> > > Is that correct?
> >
> > Correct.  David's tree hangs at a later point though, after printing
> > "Console: ... 80x25".
>
> I presume David's bk tree plus this patch also hung on your machine?
> http://www.gelato.unsw.edu.au/linux-ia64/0406/10162.html

Yep.  It gets as far as David's tree plus your patches from this morning.

Jesse

Linux version 2.6.7 (jbarnes@tomahawk.engr.sgi.com) (gcc version 3.3.2) #2 SMP 
Tue Jun 29 11:10:12 PDT 2004
EFI v1.02 by SGI: SALsystab=0x230047e5150 ACPI 2.0=0x230047e5920
ACPI: RSDP (v002    SGI                                    ) @ 
0x00000230047e5920
ACPI: XSDT (v001    SGI  XSDTSN2 0x00010001  0x00000001) @ 0x00000230047e5960
ACPI: MADT (v001    SGI  APICSN2 0x00010001  0x00000001) @ 0x00000230047e59c0
ACPI: SRAT (v001    SGI  SRATSN2 0x00010001  0x00000001) @ 0x00000230047e5a30
ACPI: SLIT (v001    SGI  SLITSN2 0x00010001  0x00000001) @ 0x00000230047e5b00
ACPI: FADT (v003    SGI  FACPSN2 0x00030001  0x00000001) @ 0x00000230047e5c00
ACPI: DSDT (v001    SGI  DSDTSN2 0x00010001  0x00000001) @ 0x00000230047e5bc0
ACPI: DSDT (v001    SGI  DSDTSN2 0x00010001  0x00000001) @ 0x0000000000000000
ACPI: SRAT revision 0
ACPI: SLIT localities 6x6
Number of logical nodes in system = 2
Number of memory chunks in system = 2
SAL 2.9: SGI SN2 version 3.32
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12
