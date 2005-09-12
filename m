From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 12 Sep 2005 14:48:52 +0000
Subject: [patch 2.6.13] ia64: add EXPORT_SYMBOL_GPL for ia64_max_cacheline_size
Message-Id: <09122005104852.31327@bilbo.tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: tony.luck@intel.com

The implementation of dma_get_cache_alignment for ia64 makes reference
to ia64_max_cacheline_size inside of a static inline. For this to
work for modules, this needs to be EXPORT_SYMBOL{,_GPL}.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 arch/ia64/kernel/setup.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -79,6 +79,7 @@ unsigned long vga_console_iobase;
 unsigned long vga_console_membase;
 
 unsigned long ia64_max_cacheline_size;
+EXPORT_SYMBOL_GPL(ia64_max_cacheline_size);
 unsigned long ia64_iobase;	/* virtual address for I/O accesses */
 EXPORT_SYMBOL(ia64_iobase);
 struct io_space io_space[MAX_IO_SPACES];
