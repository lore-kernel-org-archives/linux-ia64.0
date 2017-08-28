From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 28 Aug 2017 06:26:29 +0000
Subject: Re: [PATCH 12/12] dma-mapping: turn dma_cache_sync into a dma_map_ops method
Message-Id: <CAMuHMdVwHx2aATKqYS7xXTjnCigoZzVFFfcZOmvNj3KcFFJehg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170827161032.22772-1-hch@lst.de> <20170827161032.22772-13-hch@lst.de>
In-Reply-To: <20170827161032.22772-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Michal Simek <monstr@monstr.eu>, David Howells <dhowells@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Linux MIPS Mailing List <linux-mips@linux-mips.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Linux-sh list <linux-sh@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Christoph,

On Sun, Aug 27, 2017 at 6:10 PM, Christoph Hellwig <hch@lst.de> wrote:
> After we removed all the dead wood it turns out only two architectures
> actually implement dma_cache_sync as a no-op: mips and parisc.  Add

s/no-op/real op/

> a cache_sync method to struct dma_map_ops and implement it for the
> mips defualt DMA ops, and the parisc pa11 ops.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
