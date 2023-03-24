From: Mike Rapoport <rppt@kernel.org>
Date: Fri, 24 Mar 2023 05:22:29 +0000
Subject: [PATCH v2 10/14] powerpc: drop ranges for definition of ARCH_FORCE_MAX_ORDER
Message-Id: <20230324052233.2654090-11-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230324052233.2654090-1-rppt@kernel.org>
In-Reply-To: <20230324052233.2654090-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@kernel.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Zi Yan <ziy@nvidia.com>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

From: "Mike Rapoport (IBM)" <rppt@kernel.org>

PowerPC defines ranges for ARCH_FORCE_MAX_ORDER some of which are
insanely allowing MAX_ORDER up to 63, which implies maximal contiguous
allocation size of 2^63 pages.

Drop bogus definitions of ranges for ARCH_FORCE_MAX_ORDER and leave it a
simple integer with sensible defaults.

Users that *really* need to change the value of ARCH_FORCE_MAX_ORDER
will be able to do so but they won't be mislead by the bogus ranges.

Signed-off-by: Mike Rapoport (IBM) <rppt@kernel.org>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/powerpc/Kconfig | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index c0095bf795ca..419be4a71004 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -897,17 +897,11 @@ config DATA_SHIFT
 
 config ARCH_FORCE_MAX_ORDER
 	int "Order of maximal physically contiguous allocations"
-	range 7 8 if PPC64 && PPC_64K_PAGES
 	default "8" if PPC64 && PPC_64K_PAGES
-	range 12 12 if PPC64 && !PPC_64K_PAGES
 	default "12" if PPC64 && !PPC_64K_PAGES
-	range 8 63 if PPC32 && PPC_16K_PAGES
 	default "8" if PPC32 && PPC_16K_PAGES
-	range 6 63 if PPC32 && PPC_64K_PAGES
 	default "6" if PPC32 && PPC_64K_PAGES
-	range 4 63 if PPC32 && PPC_256K_PAGES
 	default "4" if PPC32 && PPC_256K_PAGES
-	range 10 63
 	default "10"
 	help
 	  The kernel page allocator limits the size of maximal physically
-- 
2.35.1
