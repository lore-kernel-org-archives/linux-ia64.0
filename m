From: Mike Rapoport <rppt@kernel.org>
Date: Sun, 29 Jan 2023 12:42:31 +0000
Subject: [PATCH v2 0/4] mm, arch: add generic implementation of pfn_valid() for FLATMEM
Message-Id: <20230129124235.209895-1-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Brian Cain <bcain@quicinc.com>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Guo Ren <guoren@kernel.org>, Helge Deller <deller@gmx.de>, Huacai Chen <chenhuacai@kernel.org>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@dabbelt.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Vineet Gupta <vgupta@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, loongarch@lists.linux.dev, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, x86@kernel.org, "Mike Rapoport (IBM)" <rppt@kernel.org>

From: "Mike Rapoport (IBM)" <rppt@kernel.org>

Hi,

Every architecture that supports FLATMEM memory model defines its own
version of pfn_valid() that essentially compares a pfn to max_mapnr.

Use mips/powerpc version implemented as static inline as a generic
implementation of pfn_valid() and drop its per-architecture definitions

v2:
* fix build on ARM and xtensa
* add Acked- and Reviewed-by, thanks everybody

v1: https://lore.kernel.org/all/20230125190757.22555-1-rppt@kernel.org

Mike Rapoport (IBM) (4):
  arm: include asm-generic/memory_model.h from page.h rather than
    memory.h
  m68k: use asm-generic/memory_model.h for both MMU and !MMU
  mips: drop definition of pfn_valid() for DISCONTIGMEM
  mm, arch: add generic implementation of pfn_valid() for FLATMEM

 arch/alpha/include/asm/page.h      |  4 ----
 arch/arc/include/asm/page.h        |  1 -
 arch/arm/include/asm/memory.h      |  2 --
 arch/arm/include/asm/page.h        |  2 ++
 arch/csky/include/asm/page.h       |  1 -
 arch/hexagon/include/asm/page.h    |  1 -
 arch/ia64/include/asm/page.h       |  4 ----
 arch/loongarch/include/asm/page.h  | 13 -------------
 arch/m68k/include/asm/page.h       |  6 +-----
 arch/m68k/include/asm/page_mm.h    |  1 -
 arch/m68k/include/asm/page_no.h    |  4 ----
 arch/microblaze/include/asm/page.h |  1 -
 arch/mips/include/asm/page.h       | 28 ----------------------------
 arch/nios2/include/asm/page.h      |  9 ---------
 arch/openrisc/include/asm/page.h   |  2 --
 arch/parisc/include/asm/page.h     |  4 ----
 arch/powerpc/include/asm/page.h    |  9 ---------
 arch/riscv/include/asm/page.h      |  5 -----
 arch/sh/include/asm/page.h         |  3 ---
 arch/sparc/include/asm/page_32.h   |  1 -
 arch/um/include/asm/page.h         |  1 -
 arch/x86/include/asm/page_32.h     |  4 ----
 arch/x86/include/asm/page_64.h     |  4 ----
 arch/xtensa/include/asm/page.h     |  4 ++--
 include/asm-generic/memory_model.h | 12 ++++++++++++
 include/asm-generic/page.h         |  2 --
 26 files changed, 17 insertions(+), 111 deletions(-)


base-commit: 2241ab53cbb5cdb08a6b2d4688feb13971058f65
-- 
2.35.1
