From: Russ Anderson <rja@sgi.com>
Date: Tue, 21 Oct 2008 21:15:09 +0000
Subject: [PATCH] Add UV watchlist support
Message-Id: <20081021211509.GB127371@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add UV watchlist support.

Signed-off-by: Russ Anderson <rja@sgi.com>
---
This is used by SGI xp drivers (drivers/misc/sgi-xp).



 arch/ia64/include/asm/sn/sn_sal.h |   45 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

Index: test/arch/ia64/include/asm/sn/sn_sal.h
=================================--- test.orig/arch/ia64/include/asm/sn/sn_sal.h	2008-10-20 15:15:48.647287983 -0500
+++ test/arch/ia64/include/asm/sn/sn_sal.h	2008-10-21 15:55:48.571396776 -0500
@@ -90,6 +90,8 @@
 #define  SN_SAL_SET_CPU_NUMBER			   0x02000068
 
 #define  SN_SAL_KERNEL_LAUNCH_EVENT		   0x02000069
+#define  SN_SAL_WATCHLIST_ALLOC			   0x02000070
+#define  SN_SAL_WATCHLIST_FREE			   0x02000071
 
 /*
  * Service-specific constants
@@ -1183,6 +1185,49 @@ ia64_sn_kernel_launch_event(void)
 {
  	struct ia64_sal_retval rv;
 	SAL_CALL_NOLOCK(rv, SN_SAL_KERNEL_LAUNCH_EVENT, 0, 0, 0, 0, 0, 0, 0);
+	return rv.status;
+}
+
+union sn_watchlist_u {
+	u64     val;
+	struct {
+		u64	blade	: 16,
+			size	: 32,
+			filler	: 16;
+	};
+};
+
+static inline int
+sn_mq_watchlist_alloc(int blade, void *mq, unsigned int mq_size,
+				unsigned long *intr_mmr_offset)
+{
+	struct ia64_sal_retval rv;
+	unsigned long addr;
+	union sn_watchlist_u size_blade;
+	int watchlist;
+
+	addr = (unsigned long)mq;
+	size_blade.size = mq_size;
+	size_blade.blade = blade;
+
+	/*
+	 * bios returns watchlist number or negative error number.
+	 */
+	ia64_sal_oemcall_nolock(&rv, SN_SAL_WATCHLIST_ALLOC, addr,
+			size_blade.val, (u64)intr_mmr_offset,
+			(u64)&watchlist, 0, 0, 0);
+	if (rv.status < 0)
+		return rv.status;
+
+	return watchlist;
+}
+
+static inline int
+sn_mq_watchlist_free(int blade, int watchlist_num)
+{
+	struct ia64_sal_retval rv;
+	ia64_sal_oemcall_nolock(&rv, SN_SAL_WATCHLIST_FREE, blade,
+			watchlist_num, 0, 0, 0, 0, 0);
 	return rv.status;
 }
 #endif /* _ASM_IA64_SN_SN_SAL_H */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
