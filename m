From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 06 Nov 2019 18:16:38 +0000
Subject: Re: [PATCH 11/21] asm-generic: don't provide ioremap for CONFIG_MMU
Message-Id: <CAMuHMdVuDp_8UDeWv8tdPAH5JS84=-yfwZjOk-YQcoYKM9za+w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-12-hch@lst.de> <mhng-33ea9141-2440-4a2d-8133-62094486fc48@palmer-si-x1c4>
In-Reply-To: <mhng-33ea9141-2440-4a2d-8133-62094486fc48@palmer-si-x1c4>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Palmer Dabbelt <palmer@dabbelt.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Guo Ren <guoren@kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-riscv@lists.infradead.org, Vincent Chen <deanbo422@gmail.com>, Linux-Arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, linux-xtensa@linux-xtensa.org, Arnd Bergmann <arnd@arndb.de>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Openrisc <openrisc@lists.librecores.org>, Greentime Hu <green.hu@gmail.com>, MTD

Hi Palmer,

On Wed, Nov 6, 2019 at 7:11 PM Palmer Dabbelt <palmer@dabbelt.com> wrote:
> It looks like the difference in prototype between the architectures is between
>
>     void __iomem *ioremap(resource_size_t, size_t)
>     void __iomem *ioremap(phys_addr_t, size_t)
>     void __iomem *ioremap(phys_addr_t, unsigned long)
>     void __iomem *ioremap(unsigned long, unsigned long)
>
> shouldn't they all just be that first one?  In other words, wouldn't it be
> better to always provide the generic ioremap prototype and unify the ports
> instead?

Agreed. But I'd go for the second one.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
