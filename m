From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 06 Jul 2022 10:04:23 +0000
Subject: Re: [PATCH V6 26/26] mm/mmap: Drop ARCH_HAS_VM_GET_PAGE_PROT
Message-Id: <CAMuHMdVJiS6vm2td-PBH3zpsNZJeeoudS4+yu4JG08sOi+XFdA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220630051630.1718927-1-anshuman.khandual@arm.com> <20220630051630.1718927-27-anshuman.khandual@arm.com>
In-Reply-To: <20220630051630.1718927-27-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, Christoph Hellwig <hch@lst.de>, linux-s390 <linux-s390@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Christoph Hellwig <hch@infradead.org>, arcml <linux-snps-arc@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linux-um <linux-um@lists.infradead.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Openrisc <openrisc@lists.librecores.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Parisc List <linux-parisc@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, alpha <linux-alpha@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Jun 30, 2022 at 7:20 AM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
> Now all the platforms enable ARCH_HAS_GET_PAGE_PROT. They define and export
> own vm_get_page_prot() whether custom or standard DECLARE_VM_GET_PAGE_PROT.
> Hence there is no need for default generic fallback for vm_get_page_prot().
> Just drop this fallback and also ARCH_HAS_GET_PAGE_PROT mechanism.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

>  arch/m68k/Kconfig       |  1 -

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
