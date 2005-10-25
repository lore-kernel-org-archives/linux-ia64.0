From: Russ Anderson <rja@sgi.com>
Date: Tue, 25 Oct 2005 22:34:19 +0000
Subject: [PATCH] fix bte_copy() calling get_nasid() while preemptible
Message-Id: <200510252234.j9PMYJeO56012215@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[PATCH] fix bte_copy() calling get_nasid() while preemptible

bte_copy() calls calls get_nasid(), which will get flagged if
preemption if enabled.  raw_smp_processor_id() is used instead.
It is OK if we migrate off node.

Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------
 arch/ia64/sn/kernel/bte.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: test/arch/ia64/sn/kernel/bte.c
=================================--- test.orig/arch/ia64/sn/kernel/bte.c	2005-10-25 10:46:49.311175529 -0500
+++ test/arch/ia64/sn/kernel/bte.c	2005-10-25 11:05:25.652058057 -0500
@@ -87,7 +87,7 @@ bte_result_t bte_copy(u64 src, u64 dest,
 	unsigned long irq_flags;
 	unsigned long itc_end = 0;
 	int nasid_to_try[MAX_NODES_TO_TRY];
-	int my_nasid = get_nasid();
+	int my_nasid = cpuid_to_nasid(raw_smp_processor_id());
 	int bte_if_index, nasid_index;
 	int bte_first, btes_per_node = BTES_PER_NODE;
 
