From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 11 Nov 2019 10:27:27 +0000
Subject: Re: [PATCH 10/21] asm-generic: ioremap_uc should behave the same with and without MMU
Message-Id: <CAK8P3a0rTvfPP2LUMw8EC0xz5gfZP5+NUkoaZBJrtYYfr6YRig@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-1-hch@lst.de> <20191029064834.23438-11-hch@lst.de>
 <CAK8P3a2o4R+E2hTrHrmNy7K1ki3_98aWE5a-fjkQ_NWW=xd_gQ@mail.gmail.com> <20191111101531.GA12294@lst.de>
In-Reply-To: <20191111101531.GA12294@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, the arch/x86 maintainers <x86@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, "moderated list:NIOS2 ARCHITECTURE" <nios2-dev@lists.rocketboards.org>, openrisc@lists.librecores.org, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv@lists.infradead.org, linux-s390 <linux-s390@vger.kernel.org>

On Mon, Nov 11, 2019 at 11:15 AM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Nov 11, 2019 at 11:09:05AM +0100, Arnd Bergmann wrote:
> > Maybe we could move the definition into the atyfb driver itself?
> >
> > As I understand it, the difference between ioremap()/ioremap_nocache()
> > and ioremap_uc() only exists on pre-PAT x86-32 systems (i.e. 486, P5,
> > Ppro, PII, K6, VIA C3), while on more modern systems (all non-x86,
> > PentiumIII, Athlon, VIA C7)  those three are meant to be synonyms
> > anyway.
>
> That's not how I understood it.  Based on the code and the UC-
> explanation ioremap_uc always overrides the MTRR, which can still
> be present on more modern x86 systems.

As I understand, the point is that on PAT-enabled systems, the
normal ioremap() *also* overrides the MTRR, citing from
Documentation/x86/pat.rst:

  ==  ====  ==  =============  ==========  MTRR  Non-PAT  PAT  Linux ioremap value        Effective memory type
  ==  ====  ==  =============  ==========        PAT                                        Non-PAT |  PAT
        |PCD                                               |
        ||PWT                                              |
        |||                                                |
  WC    000      WB   _PAGE_CACHE_MODE_WB             WC   |   WC
  WC    001      WC   _PAGE_CACHE_MODE_WC             WC*  |   WC
  WC    010      UC-  _PAGE_CACHE_MODE_UC_MINUS       WC*  |   UC
  WC    011      UC   _PAGE_CACHE_MODE_UC             UC   |   UC
  ==  ====  ==  =============  ==========
> In fact I remember a patch
> floating around very recently adding another ioremap_uc caller in
> some Atom platform device driver that works around buggy MTRR
> tables.  Also this series actually adds a new override and a few
> callers for ia64 platform code, which works very similar to x86
> based on the comments in the code.  That being said I'm not sure
> the callers in ia64 are really required, but it was the safest thing
> to do as part of this cleanup.

Ok, fair enough. Let's just go with your version for now, if only to not
hold your series up more. I'd still suggest we change atyfb to only
use ioremap_uc() on i386 and maybe ia64. I can send a patch for that.

      Arnd
