From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 11 Nov 2019 19:33:17 +0000
Subject: Re: [PATCH 10/21] asm-generic: ioremap_uc should behave the same with and without MMU
Message-Id: <CAK8P3a2b=td4JhYOcK1jUshh8Mp-5_w4v+dAr_JjnH783=ptBQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-1-hch@lst.de> <20191029064834.23438-11-hch@lst.de>
 <CAK8P3a2o4R+E2hTrHrmNy7K1ki3_98aWE5a-fjkQ_NWW=xd_gQ@mail.gmail.com>
 <20191111101531.GA12294@lst.de> <CAK8P3a0rTvfPP2LUMw8EC0xz5gfZP5+NUkoaZBJrtYYfr6YRig@mail.gmail.com>
 <20191111102923.GA12974@lst.de>
In-Reply-To: <20191111102923.GA12974@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, the arch/x86 maintainers <x86@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, "moderated list:NIOS2 ARCHITECTURE" <nios2-dev@lists.rocketboards.org>, openrisc@lists.librecores.org, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv@lists.infradead.org, linux-s390 <linux-s390@vger.kernel.org>

On Mon, Nov 11, 2019 at 11:29 AM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Nov 11, 2019 at 11:27:27AM +0100, Arnd Bergmann wrote:
> > Ok, fair enough. Let's just go with your version for now, if only to not
> > hold your series up more. I'd still suggest we change atyfb to only
> > use ioremap_uc() on i386 and maybe ia64. I can send a patch for that.
>
> I don't think we even need it on ia64.  But lets kick off a dicussion
> with the atyfb, x86 and ia64 maintainers after this series is in.
> Which was kinda my plan anyway.

I missed your reply and already sent my patch now. I guess it doesn't
hurt to discuss that in parallel. Anyway I think that this patch is the
last one you want an Ack from me for (let me know if I missed one), so

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
