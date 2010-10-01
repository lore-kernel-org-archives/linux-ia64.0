From: akpm@linux-foundation.org
Date: Fri, 01 Oct 2010 21:15:27 +0000
Subject: [patch 1/1] ia64: enable ARCH_DMA_ADDR_T_64BIT
Message-Id: <201010012115.o91LFRPE021082@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/Kconfig |    3 +++
 1 file changed, 3 insertions(+)

diff -puN arch/ia64/Kconfig~ia64-enable-arch_dma_addr_t_64bit arch/ia64/Kconfig
--- a/arch/ia64/Kconfig~ia64-enable-arch_dma_addr_t_64bit
+++ a/arch/ia64/Kconfig
@@ -46,6 +46,9 @@ config MMU
 	bool
 	default y
 
+config ARCH_DMA_ADDR_T_64BIT
+	def_bool y
+
 config NEED_DMA_MAP_STATE
 	def_bool y
 
_
