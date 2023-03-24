From: Mike Rapoport <rppt@kernel.org>
Date: Fri, 24 Mar 2023 05:22:21 +0000
Subject: [PATCH v2 02/14] arm64: drop ranges in definition of ARCH_FORCE_MAX_ORDER
Message-Id: <20230324052233.2654090-3-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230324052233.2654090-1-rppt@kernel.org>
In-Reply-To: <20230324052233.2654090-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@kernel.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Zi Yan <ziy@nvidia.com>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

From: "Mike Rapoport (IBM)" <rppt@kernel.org>

It is not a good idea to change fundamental parameters of core memory
management. Having predefined ranges suggests that the values within
those ranges are sensible, but one has to *really* understand
implications of changing MAX_ORDER before actually amending it and
ranges don't help here.

Drop ranges in definition of ARCH_FORCE_MAX_ORDER and make its prompt
visible only if EXPERT=y

Signed-off-by: Mike Rapoport (IBM) <rppt@kernel.org>
---
 arch/arm64/Kconfig | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index e60baf7859d1..7324032af859 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -1487,11 +1487,9 @@ config XEN
 # 16K |       27          |      14      |       13        |         11         |
 # 64K |       29          |      16      |       13        |         13         |
 config ARCH_FORCE_MAX_ORDER
-	int "Maximum zone order" if ARM64_4K_PAGES || ARM64_16K_PAGES
+	int "Maximum zone order" if EXPERT && (ARM64_4K_PAGES || ARM64_16K_PAGES)
 	default "13" if ARM64_64K_PAGES
-	range 11 13 if ARM64_16K_PAGES
 	default "11" if ARM64_16K_PAGES
-	range 10 15 if ARM64_4K_PAGES
 	default "10"
 	help
 	  The kernel memory allocator divides physically contiguous memory
-- 
2.35.1
