From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Wed, 13 Mar 2019 17:38:17 +0000
Subject: Re: [PATCH] ia64: prefix header search path with $(srctree)/
Message-Id: <CAK7LNAQES1uci6MucHCE2dN2bKV3grLzLi76Q=ycYqCAWzWwRw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548400703-27945-1-git-send-email-yamada.masahiro@socionext.com> <CAK7LNARf-P0Qjj2ScgQHk2yFw13h7zXk0VCB0MJe3W2ka3s40A@mail.gmail.com>
In-Reply-To: <CAK7LNARf-P0Qjj2ScgQHk2yFw13h7zXk0VCB0MJe3W2ka3s40A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Feb 18, 2019 at 1:54 PM Masahiro Yamada
<yamada.masahiro@socionext.com> wrote:
>
> On Fri, Jan 25, 2019 at 4:21 PM Masahiro Yamada
> <yamada.masahiro@socionext.com> wrote:
> >
> > Currently, the Kbuild core manipulates header search paths in a crazy
> > way [1].
> >
> > To fix this mess, I want all Makefiles to add explicit $(srctree)/ to
> > the search paths in the srctree. Some Makefiles are already written in
> > that way, but not all. The goal of this work is to make the notation
> > consistent, and finally get rid of the gross hacks.
> >
> > Having whitespaces after -I does not matter since commit 48f6e3cf5bc6
> > ("kbuild: do not drop -I without parameter").
> >
> > I removed some header search paths because I was able to build ia64
> > without them.
> >
> > [1]: https://patchwork.kernel.org/patch/9632347/
> >
> > Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> > ---
>
>
> ia64 development is not very active these days.
>
> I will wait for response from the maintainers.
>
> If they are silent, I want to pick up this to my kbuild tree.


Applied to linux-kbuild.




>
> Thanks.
>
>
> >  arch/ia64/sn/kernel/Makefile     | 2 +-
> >  arch/ia64/sn/kernel/sn2/Makefile | 2 --
> >  arch/ia64/sn/pci/Makefile        | 2 --
> >  arch/ia64/sn/pci/pcibr/Makefile  | 2 +-
> >  4 files changed, 2 insertions(+), 6 deletions(-)
> >
> > diff --git a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
> > index d27df1d..9c349dd 100644
> > --- a/arch/ia64/sn/kernel/Makefile
> > +++ b/arch/ia64/sn/kernel/Makefile
> > @@ -7,7 +7,7 @@
> >  # Copyright (C) 1999,2001-2006,2008 Silicon Graphics, Inc.  All Rights Reserved.
> >  #
> >
> > -ccflags-y := -Iarch/ia64/sn/include
> > +ccflags-y := -I $(srctree)/arch/ia64/sn/include
> >
> >  obj-y                          += setup.o bte.o bte_error.o irq.o mca.o idle.o \
> >                                    huberror.o io_acpi_init.o io_common.o \
> > diff --git a/arch/ia64/sn/kernel/sn2/Makefile b/arch/ia64/sn/kernel/sn2/Makefile
> > index 3d09108..170bde4 100644
> > --- a/arch/ia64/sn/kernel/sn2/Makefile
> > +++ b/arch/ia64/sn/kernel/sn2/Makefile
> > @@ -9,7 +9,5 @@
> >  # sn2 specific kernel files
> >  #
> >
> > -ccflags-y := -Iarch/ia64/sn/include
> > -
> >  obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
> >          prominfo_proc.o timer.o timer_interrupt.o sn_hwperf.o
> > diff --git a/arch/ia64/sn/pci/Makefile b/arch/ia64/sn/pci/Makefile
> > index df2a901..321576b 100644
> > --- a/arch/ia64/sn/pci/Makefile
> > +++ b/arch/ia64/sn/pci/Makefile
> > @@ -7,6 +7,4 @@
> >  #
> >  # Makefile for the sn pci general routines.
> >
> > -ccflags-y := -Iarch/ia64/sn/include
> > -
> >  obj-y := pci_dma.o tioca_provider.o tioce_provider.o pcibr/
> > diff --git a/arch/ia64/sn/pci/pcibr/Makefile b/arch/ia64/sn/pci/pcibr/Makefile
> > index 396bcae..712f6af 100644
> > --- a/arch/ia64/sn/pci/pcibr/Makefile
> > +++ b/arch/ia64/sn/pci/pcibr/Makefile
> > @@ -7,7 +7,7 @@
> >  #
> >  # Makefile for the sn2 io routines.
> >
> > -ccflags-y := -Iarch/ia64/sn/include
> > +ccflags-y := -I $(srctree)/arch/ia64/sn/include
> >
> >  obj-y                          +=  pcibr_dma.o pcibr_reg.o \
> >                                     pcibr_ate.o pcibr_provider.o
> > --
> > 2.7.4
> >
>
>
> --
> Best Regards
> Masahiro Yamada



-- 
Best Regards
Masahiro Yamada
