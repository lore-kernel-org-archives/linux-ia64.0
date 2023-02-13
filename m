From: Mike Rapoport <rppt@kernel.org>
Date: Mon, 13 Feb 2023 01:26:39 +0000
Subject: Re: [PATCH v2 4/4] mm, arch: add generic implementation of pfn_valid() for FLATMEM
Message-Id: <Y+mRz6Wfocopv9jw@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230129124235.209895-1-rppt@kernel.org>
 <20230129124235.209895-5-rppt@kernel.org>
 <20230212161320.GA3784076@roeck-us.net>
In-Reply-To: <20230212161320.GA3784076@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Brian Cain <bcain@quicinc.com>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Guo Ren <guoren@kernel.org>, Helge Deller <deller@gmx.de>, Huacai Chen <chenhuacai@kernel.org>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@dabbelt.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Vineet Gupta <vgupta@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, loongarch@lists.linux.dev, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, x86@kernel.org, Huacai Chen <chenhuacai@loongson.cn>

On Sun, Feb 12, 2023 at 08:13:20AM -0800, Guenter Roeck wrote:
> On Sun, Jan 29, 2023 at 02:42:35PM +0200, Mike Rapoport wrote:
> > From: "Mike Rapoport (IBM)" <rppt@kernel.org>
> > 
> > Every architecture that supports FLATMEM memory model defines its own
> > version of pfn_valid() that essentially compares a pfn to max_mapnr.
> > 
> > Use mips/powerpc version implemented as static inline as a generic
> > implementation of pfn_valid() and drop its per-architecture definitions.
> > 
> 
> With this patch in the tree, sh4 and sh4eb qemu emulations no longer boot.
> Reverting this patch fixes the problem.

This should be a better fix than a revert:

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 506784702430..bf1b54055316 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -301,6 +301,7 @@ void __init paging_init(void)
 	 */
 	max_low_pfn = max_pfn = memblock_end_of_DRAM() >> PAGE_SHIFT;
 	min_low_pfn = __MEMORY_START >> PAGE_SHIFT;
+	set_max_mapnr(max_low_pfn - min_low_pfn);
 
 	nodes_clear(node_online_map);
 
 
> Guenter
> 
> ---
> # bad: [6ba8a227fd19d19779005fb66ad7562608e1df83] Add linux-next specific files for 20230210
> # good: [4ec5183ec48656cec489c49f989c508b68b518e3] Linux 6.2-rc7
> git bisect start 'HEAD' 'v6.2-rc7'
> # good: [94613f0efc69ed41f9229ef5c294db3ec37145da] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/herbert/cryptodev-2.6.git
> git bisect good 94613f0efc69ed41f9229ef5c294db3ec37145da
> # good: [19e62c715fe70dae4582c2874ed3e66715d09af6] Merge branch 'rcu/next' of git://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-rcu.git
> git bisect good 19e62c715fe70dae4582c2874ed3e66715d09af6
> # good: [5d8b7ecef7f4a681b6e5538db59ff26c389c0ab6] Merge branch 'for-next' of https://gitlab.com/peda-linux/mux.git
> git bisect good 5d8b7ecef7f4a681b6e5538db59ff26c389c0ab6
> # good: [c349bf6ec83903b20fe570c5609b9a864a64e09c] Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/krisman/unicode.git
> git bisect good c349bf6ec83903b20fe570c5609b9a864a64e09c
> # good: [5a06a9f17454df38f35672be522ff5eb9b4277d2] selftest: add testing unsharing and counting ksm zero page
> git bisect good 5a06a9f17454df38f35672be522ff5eb9b4277d2
> # bad: [f5d115a7b06e5661ed5218ffa9a2644c4ff1c135] Merge branch 'mm-nonmm-unstable' into mm-everything
> git bisect bad f5d115a7b06e5661ed5218ffa9a2644c4ff1c135
> # bad: [acb018d6ea0c055381fba7dddaef386ee28f8075] mm/vmalloc.c: allow vread() to read out vm_map_ram areas
> git bisect bad acb018d6ea0c055381fba7dddaef386ee28f8075
> # good: [1a5d9782ac969dc6e61c6786500b5160603188ea] mm/mmap: remove __vma_adjust()
> git bisect good 1a5d9782ac969dc6e61c6786500b5160603188ea
> # good: [4b32363697de957dcc890b6245bec3f58903639a] arm: include asm-generic/memory_model.h from page.h rather than memory.h
> git bisect good 4b32363697de957dcc890b6245bec3f58903639a
> # bad: [328cf3fa6682ce6a4de6f8bb8009c833dc33f3c8] mm/migrate: convert isolate_movable_page() to use folios
> git bisect bad 328cf3fa6682ce6a4de6f8bb8009c833dc33f3c8
> # bad: [b704c765b08cabe82adf76a4d1a74f3688eee410] mm/mempolicy: convert queue_pages_pmd() to queue_folios_pmd()
> git bisect bad b704c765b08cabe82adf76a4d1a74f3688eee410
> # bad: [e5734c8b0edfd2a053a5c256189586a3b1e9f63d] mm, arch: add generic implementation of pfn_valid() for FLATMEM
> git bisect bad e5734c8b0edfd2a053a5c256189586a3b1e9f63d
> # good: [ad8aecea034c591b9754bc5908da9719853aa7fa] mips: drop definition of pfn_valid() for DISCONTIGMEM
> git bisect good ad8aecea034c591b9754bc5908da9719853aa7fa
> # first bad commit: [e5734c8b0edfd2a053a5c256189586a3b1e9f63d] mm, arch: add generic implementation of pfn_valid() for FLATMEM

-- 
Sincerely yours,
Mike.
