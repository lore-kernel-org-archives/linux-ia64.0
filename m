From: Christoph Hellwig <hch@lst.de>
Date: Mon, 11 Nov 2019 10:15:31 +0000
Subject: Re: [PATCH 10/21] asm-generic: ioremap_uc should behave the same with and without MMU
Message-Id: <20191111101531.GA12294@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-1-hch@lst.de> <20191029064834.23438-11-hch@lst.de> <CAK8P3a2o4R+E2hTrHrmNy7K1ki3_98aWE5a-fjkQ_NWW=xd_gQ@mail.gmail.com>
In-Reply-To: <CAK8P3a2o4R+E2hTrHrmNy7K1ki3_98aWE5a-fjkQ_NWW=xd_gQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Hellwig <hch@lst.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, the arch/x86 maintainers <x86@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, "moderated list:NIOS2 ARCHITECTURE" <nios2-dev@lists.rocketboards.org>, openrisc@lists.librecores.org, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv@lists.infradead.orgli

On Mon, Nov 11, 2019 at 11:09:05AM +0100, Arnd Bergmann wrote:
> Maybe we could move the definition into the atyfb driver itself?
> 
> As I understand it, the difference between ioremap()/ioremap_nocache()
> and ioremap_uc() only exists on pre-PAT x86-32 systems (i.e. 486, P5,
> Ppro, PII, K6, VIA C3), while on more modern systems (all non-x86,
> PentiumIII, Athlon, VIA C7)  those three are meant to be synonyms
> anyway.

That's not how I understood it.  Based on the code and the UC-
explanation ioremap_uc always overrides the MTRR, which can still
be present on more modern x86 systems.  In fact I remember a patch
floating around very recently adding another ioremap_uc caller in
some Atom platform device driver that works around buggy MTRR
tables.  Also this series actually adds a new override and a few
callers for ia64 platform code, which works very similar to x86
based on the comments in the code.  That being said I'm not sure
the callers in ia64 are really required, but it was the safest thing
to do as part of this cleanup.
