From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 11 Nov 2019 10:31:05 +0000
Subject: Re: [PATCH 11/21] asm-generic: don't provide ioremap for CONFIG_MMU
Message-Id: <CAK8P3a2a7jwmAKhh3WsowCmvdQpsde5A5nz+3NXRn7amhwUxQg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-12-hch@lst.de> <mhng-33ea9141-2440-4a2d-8133-62094486fc48@palmer-si-x1c4>
 <CAMuHMdVuDp_8UDeWv8tdPAH5JS84=-yfwZjOk-YQcoYKM9za+w@mail.gmail.com>
In-Reply-To: <CAMuHMdVuDp_8UDeWv8tdPAH5JS84=-yfwZjOk-YQcoYKM9za+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Palmer Dabbelt <palmer@dabbelt.com>, Christoph Hellwig <hch@lst.de>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Guo Ren <guoren@kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-riscv@lists.infradead.org, Vincent Chen <deanbo422@gmail.com>, Linux-Arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, linux-xtensa@linux-xtensa.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, Openrisc <openrisc@lists.librecores.org>, Greentime Hu <green.hu@gmail.com>

On Wed, Nov 6, 2019 at 7:16 PM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>
> Hi Palmer,
>
> On Wed, Nov 6, 2019 at 7:11 PM Palmer Dabbelt <palmer@dabbelt.com> wrote:
> > It looks like the difference in prototype between the architectures is between
> >
> >     void __iomem *ioremap(resource_size_t, size_t)
> >     void __iomem *ioremap(phys_addr_t, size_t)
> >     void __iomem *ioremap(phys_addr_t, unsigned long)
> >     void __iomem *ioremap(unsigned long, unsigned long)
> >
> > shouldn't they all just be that first one?  In other words, wouldn't it be
> > better to always provide the generic ioremap prototype and unify the ports
> > instead?
>
> Agreed. But I'd go for the second one.

Right, phys_addr_t is the correct type here, resource_size_t is just a generic
type that is at least as long as any resource, and usually the same as
phys_addr_t, which is supposed to be used for physical addresses.

      Arnd
