From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 07 Jun 2021 08:53:08 +0000
Subject: Re: [PATCH v2 8/9] mm: replace CONFIG_NEED_MULTIPLE_NODES with CONFIG_NUMA
Message-Id: <CAMuHMdVa29gUQAdHjKh-qDNpOJaoGwXtUkBM2qnOTi1DWV70xA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210604064916.26580-1-rppt@kernel.org> <20210604064916.26580-9-rppt@kernel.org>
In-Reply-To: <20210604064916.26580-9-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, Vineet Gupta <vgupta@synopsys.com>, kexec@lists.infradead.org, alpha <linux-alpha@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>

Hi Mike,

On Fri, Jun 4, 2021 at 8:50 AM Mike Rapoport <rppt@kernel.org> wrote:
> From: Mike Rapoport <rppt@linux.ibm.com>
>
> After removal of DISCINTIGMEM the NEED_MULTIPLE_NODES and NUMA
> configuration options are equivalent.
>
> Drop CONFIG_NEED_MULTIPLE_NODES and use CONFIG_NUMA instead.
>
> Done with
>
>         $ sed -i 's/CONFIG_NEED_MULTIPLE_NODES/CONFIG_NUMA/' \
>                 $(git grep -wl CONFIG_NEED_MULTIPLE_NODES)
>         $ sed -i 's/NEED_MULTIPLE_NODES/NUMA/' \
>                 $(git grep -wl NEED_MULTIPLE_NODES)
>
> with manual tweaks afterwards.
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Thanks for your patch!

As you dropped the following hunk from v2 of PATCH 5/9, there's now
one reference left of CONFIG_NEED_MULTIPLE_NODES
(plus the discontigmem comment):

-diff --git a/mm/memory.c b/mm/memory.c
-index f3ffab9b9e39157b..fd0ebb63be3304f5 100644
---- a/mm/memory.c
-+++ b/mm/memory.c
-@@ -90,8 +90,7 @@
- #warning Unfortunate NUMA and NUMA Balancing config, growing
page-frame for last_cpupid.
- #endif
-
--#ifndef CONFIG_NEED_MULTIPLE_NODES
--/* use the per-pgdat data instead for discontigmem - mbligh */
-+#ifdef CONFIG_FLATMEM
- unsigned long max_mapnr;
- EXPORT_SYMBOL(max_mapnr);
-

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
