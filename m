From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 24 Jan 2014 01:53:14 +0000
Subject: [PATCH 5/5] ia64: fix warnings
Message-Id: <alpine.LRH.2.02.1401232047560.16873@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LRH.2.02.1401232041520.16873@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1401232043320.16873@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1401232044180.16873@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1401232045350.16873@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1401232046500.16873@file01.intranet.prod.int.rdu2.redhat.com>
In-Reply-To: <alpine.LRH.2.02.1401232046500.16873@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Fix some warnings in ia64:

arch/ia64/kernel/sys_ia64.c:29:20: warning: unused variable 'mm'
[-Wunused-variable]

arch/ia64/sn/kernel/setup.c:582:23: warning: argument to 'sizeof' in
'memset' call is the same pointer type 'struct pda_s *' as the
destination; expected 'struct pda_s' or an explicit length
[-Wsizeof-pointer-memaccess]	(this is a real bug!)

arch/ia64/sn/kernel/bte.c:117:22: warning: cast from pointer to integer of
different size [-Wpointer-to-int-cast]

arch/ia64/sn/kernel/bte.c:125:22: warning: cast from pointer to integer of
different size [-Wpointer-to-int-cast]

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com

---
 arch/ia64/kernel/sys_ia64.c |    3 +--
 arch/ia64/sn/kernel/bte.c   |    4 ++--
 arch/ia64/sn/kernel/setup.c |    2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

Index: linux-2.6-ia64/arch/ia64/kernel/sys_ia64.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/sys_ia64.c	2014-01-24 02:20:52.000000000 +0100
+++ linux-2.6-ia64/arch/ia64/kernel/sys_ia64.c	2014-01-24 02:21:16.000000000 +0100
@@ -26,7 +26,6 @@ arch_get_unmapped_area (struct file *fil
 {
 	long map_shared = (flags & MAP_SHARED);
 	unsigned long align_mask = 0;
-	struct mm_struct *mm = current->mm;
 	struct vm_unmapped_area_info info;
 
 	if (len > RGN_MAP_LIMIT)
@@ -34,7 +33,7 @@ arch_get_unmapped_area (struct file *fil
 
 	/* handle fixed mapping: prevent overlap with huge pages */
 	if (flags & MAP_FIXED) {
-		if (is_hugepage_only_range(mm, addr, len))
+		if (is_hugepage_only_range(current->mm, addr, len))
 			return -EINVAL;
 		return addr;
 	}
Index: linux-2.6-ia64/arch/ia64/sn/kernel/bte.c
=================================--- linux-2.6-ia64.orig/arch/ia64/sn/kernel/bte.c	2014-01-24 02:20:43.000000000 +0100
+++ linux-2.6-ia64/arch/ia64/sn/kernel/bte.c	2014-01-24 02:21:16.000000000 +0100
@@ -114,7 +114,7 @@ bte_result_t bte_copy(u64 src, u64 dest,
 		if (mode & BTE_USE_ANY) {
 			nasid_to_try[1] = my_nasid;
 		} else {
-			nasid_to_try[1] = (int)NULL;
+			nasid_to_try[1] = 0;
 		}
 	} else {
 		/* try local then remote */
@@ -122,7 +122,7 @@ bte_result_t bte_copy(u64 src, u64 dest,
 		if (mode & BTE_USE_ANY) {
 			nasid_to_try[1] = NASID_GET(dest);
 		} else {
-			nasid_to_try[1] = (int)NULL;
+			nasid_to_try[1] = 0;
 		}
 	}
 
Index: linux-2.6-ia64/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6-ia64.orig/arch/ia64/sn/kernel/setup.c	2014-01-24 02:20:43.000000000 +0100
+++ linux-2.6-ia64/arch/ia64/sn/kernel/setup.c	2014-01-24 02:21:16.000000000 +0100
@@ -579,7 +579,7 @@ void sn_cpu_init(void)
 		       (sn_prom_type = 1) ? "real" : "fake");
 	}
 
-	memset(pda, 0, sizeof(pda));
+	memset(pda, 0, sizeof(*pda));
 	if (ia64_sn_get_sn_info(0, &sn_hub_info->shub2,
 				&sn_hub_info->nasid_bitmask,
 				&sn_hub_info->nasid_shift,
