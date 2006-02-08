From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Feb 2006 02:41:10 +0000
Subject: [PATCH 2.6.16-rc2 3/3] MCA: remove obsolete ifdef
Message-Id: <20060208024110.9264.91992.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No platform in the community tree uses PLATFORM_MCA_HANDLERS, remove
the references.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 mca.c |    7 -------
 1 files changed, 7 deletions(-)

Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2006-02-08 12:10:15.603478247 +1100
+++ linux/arch/ia64/kernel/mca.c	2006-02-08 12:12:22.726542463 +1100
@@ -281,11 +281,6 @@ ia64_mca_log_sal_error_record(int sal_in
 		ia64_sal_clear_state_info(sal_info_type);
 }
 
-/*
- * platform dependent error handling
- */
-#ifndef PLATFORM_MCA_HANDLERS
-
 #ifdef CONFIG_ACPI
 
 int cpe_vector = -1;
@@ -377,8 +372,6 @@ ia64_mca_register_cpev (int cpev)
 }
 #endif /* CONFIG_ACPI */
 
-#endif /* PLATFORM_MCA_HANDLERS */
-
 /*
  * ia64_mca_cmc_vector_setup
  *
