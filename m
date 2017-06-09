From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 09 Jun 2017 12:20:42 +0000
Subject: Re: [PATCH 33/44] openrisc: remove arch-specific dma_supported implementation
Message-Id: <CAMuHMdUPeFJJtz8eJkQEAR-2w9oHt-fXeGHvvKFLfU2A4YyviQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de> <20170608132609.32662-34-hch@lst.de>
In-Reply-To: <20170608132609.32662-34-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: the arch/x86 maintainers <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux MIPS Mailing List <linux-mips@linux-mips.org>, openrisc@lists.librecores.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, DRI Development <dri-devel@lists.freedesktop.org>, linux-samsung-soc@vg

Hi Christoph,

On Thu, Jun 8, 2017 at 3:25 PM, Christoph Hellwig <hch@lst.de> wrote:
> This implementation is simply bogus - hexagon only has a simple

openrisc?

> direct mapped DMA implementation and thus doesn't care about the
> address.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/openrisc/include/asm/dma-mapping.h | 7 -------

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
