From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 19 Jun 2018 06:49:36 +0000
Subject: Re: Build regressions/improvements in v4.18-rc1
Message-Id: <CAMuHMdUfHJS-ykNr-vPPUDfGLsGr62c4R=EThw33-DFNj9ZQNg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180618091729.11091-1-geert@linux-m68k.org> <CAMuHMdULmiArTvYsEqnyg5SB6PqjZnNANLAyYcqqYeYmHKJ5Dw@mail.gmail.com>
 <87vaafxp0k.fsf@concordia.ellerman.id.au>
In-Reply-To: <87vaafxp0k.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

Hi Michael,

On Tue, Jun 19, 2018 at 8:35 AM Michael Ellerman <mpe@ellerman.id.au> wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
> > On Mon, Jun 18, 2018 at 11:18 AM Geert Uytterhoeven
> > <geert@linux-m68k.org> wrote:
> >> Below is the list of build error/warning regressions/improvements in
> >> v4.18-rc1[1] compared to v4.17[2].

> >>   + /kisskb/src/mm/memblock.c: error: redefinition of 'memblock_virt_alloc_try_nid':  => 1413:15
> >>   + /kisskb/src/mm/memblock.c: error: redefinition of 'memblock_virt_alloc_try_nid_nopanic':  => 1377:15
> >>   + /kisskb/src/mm/memblock.c: error: redefinition of 'memblock_virt_alloc_try_nid_raw':  => 1340:15
> >
> > ia64/ia64-defconfig
> > mips/bigsur_defconfig
> > mips/cavium_octeon_defconfig
> > mips/ip22_defconfig
> > mips/ip27_defconfig
> > mips/ip32_defconfig
> > mips/malta_defconfig
> > mips/mips-allmodconfig
> > mips/mips-allnoconfig
> > mips/mips-defconfig
> > mipsel/mips-allmodconfig
> > mipsel/mips-allnoconfig
> > mipsel/mips-defconfig
>
> These are now fixed in Linus' tree by:
>
>   6cc22dc08a24 ("revert "mm/memblock: add missing include <linux/bootmem.h>"")

Good.

> >>   + error: ".radix__flush_pwc_lpid" [arch/powerpc/kvm/kvm-hv.ko] undefined!:  => N/A
> >>   + error: ".radix__flush_tlb_lpid_page" [arch/powerpc/kvm/kvm-hv.ko] undefined!:  => N/A
> >>   + error: ".radix__local_flush_tlb_lpid_guest" [arch/powerpc/kvm/kvm-hv.ko] undefined!:  => N/A
> >>   + error: "radix__flush_pwc_lpid" [arch/powerpc/kvm/kvm-hv.ko] undefined!:  => N/A
> >>   + error: "radix__flush_tlb_lpid_page" [arch/powerpc/kvm/kvm-hv.ko] undefined!:  => N/A
> >>   + error: "radix__local_flush_tlb_lpid_guest" [arch/powerpc/kvm/kvm-hv.ko] undefined!:  => N/A
> >
> > powerpc/ppc64_defconfig+NO_RADIX
> > ppc64le/powernv_defconfig+NO_RADIX (what's in a name ;-)
>
> Can you tell we don't test that combination very often :/

That's why you have a special config for it? ;-)

> >>   + {standard input}: Error: offset to unaligned destination:  => 2268, 2316, 1691, 1362, 1455, 1598, 2502, 1645, 1988, 1927, 1409, 2615, 1548, 2409, 1268, 2363, 1314, 1208, 1785, 2034, 2222, 2661, 1880, 2552, 1161, 2082, 1833, 2455, 2176, 2129, 1501, 1738
> >
> > sh4/sh-randconfig (doesn't seem to be a new issue, seen before on v4.12-rc3)
>
> I think I'll disable that one, it's been broken more often that not and
> I doubt anyone is that motivated to fix sh4 randconfig breakages?

Probably not. Usually I ignore the commonly seen issues.
This one was more uncommon, so I kept it.

> Relatedly I might move all the randconfig targets from Linus' tree into
> a separate "linus-rand" tree, so that they don't pollute the results, as
> I've done for linux-next.

Sounds look a good thing.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
