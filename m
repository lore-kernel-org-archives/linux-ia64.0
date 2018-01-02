From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 02 Jan 2018 10:22:35 +0000
Subject: Re: [PATCH 16/67] powerpc: rename dma_direct_ to dma_nommu_
Message-Id: <CAMuHMdWWus2kNSOzS94k-3678826W1YjKwCWTquu3hBLZ80cvw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de> <20171229081911.2802-17-hch@lst.de>
 <878tdgtwzp.fsf@concordia.ellerman.id.au>
In-Reply-To: <878tdgtwzp.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Linux-Arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, adi-buildroot-devel@lists.sourceforge.net, linux-m68k <linux-m68k@lists.linux-m68k.org>, patches@groups.riscv.org, "open list:METAG ARCHITECTURE" <linux-metag@vger.kernel.org>, linux-arm-kernel@lists.infradead.orgMichalSimek

On Tue, Jan 2, 2018 at 10:45 AM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> Christoph Hellwig <hch@lst.de> writes:
>
>> We want to use the dma_direct_ namespace for a generic implementation,
>> so rename powerpc to the second best choice: dma_nommu_.
>
> I'm not a fan of "nommu". Some of the users of direct ops *are* using an
> IOMMU, they're just setting up a 1:1 mapping once at init time, rather
> than mapping dynamically.
>
> Though I don't have a good idea for a better name, maybe "1to1",
> "linear", "premapped" ?

"identity"?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
