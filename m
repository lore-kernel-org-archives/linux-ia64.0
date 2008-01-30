From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 30 Jan 2008 03:17:42 +0000
Subject: [PATCH] ia64: generalize attribute of fsyscall_gtod_data
Message-Id: <479FEC56.9050803@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In an ordinary way,

> } __attribute__ ((aligned (L1_CACHE_BYTES)));

should be

> } ____cacheline_aligned;

to save some bytes on an uni-processor.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/fsyscall_gtod_data.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.24/arch/ia64/kernel/fsyscall_gtod_data.h
=================================--- linux-2.6.24.orig/arch/ia64/kernel/fsyscall_gtod_data.h
+++ linux-2.6.24/arch/ia64/kernel/fsyscall_gtod_data.h
@@ -14,10 +14,10 @@
 	u32		clk_shift;
 	void		*clk_fsys_mmio;
 	cycle_t		clk_cycle_last;
-} __attribute__ ((aligned (L1_CACHE_BYTES)));
+} ____cacheline_aligned;

 struct itc_jitter_data_t {
 	int		itc_jitter;
 	cycle_t		itc_lastcycle;
-} __attribute__ ((aligned (L1_CACHE_BYTES)));
+} ____cacheline_aligned;

