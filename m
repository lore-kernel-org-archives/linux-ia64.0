From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 08 Apr 2008 04:33:08 +0000
Subject: [PATCH 2/2] ia64 kdump: crash.c coding style fix
Message-Id: <47FAF584.7050703@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix indenting of switch statement to follow Documentation/CodingStyle.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/crash.c |   52 +++++++++++++++++++++++------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

Index: GIT-torvalds/arch/ia64/kernel/crash.c
=================================--- GIT-torvalds.orig/arch/ia64/kernel/crash.c
+++ GIT-torvalds/arch/ia64/kernel/crash.c
@@ -174,32 +174,32 @@ kdump_init_notifier(struct notifier_bloc
 		return NOTIFY_DONE;

 	switch (val) {
-		case DIE_INIT_MONARCH_PROCESS:
-			if (kdump_on_init) {
-				atomic_set(&kdump_in_progress, 1);
-				*(nd->monarch_cpu) = -1;
-			}
-			break;
-		case DIE_INIT_MONARCH_LEAVE:
-			if (kdump_on_init)
-				machine_kdump_on_init();
-			break;
-		case DIE_INIT_SLAVE_LEAVE:
-			if (atomic_read(&kdump_in_progress))
-				unw_init_running(kdump_cpu_freeze, NULL);
-			break;
-		case DIE_MCA_RENDZVOUS_LEAVE:
-			if (atomic_read(&kdump_in_progress))
-				unw_init_running(kdump_cpu_freeze, NULL);
-			break;
-		case DIE_MCA_MONARCH_LEAVE:
-			/* die_register->signr indicate if MCA is recoverable */
-			if (kdump_on_fatal_mca && !args->signr) {
-				atomic_set(&kdump_in_progress, 1);
-				*(nd->monarch_cpu) = -1;
-				machine_kdump_on_init();
-			}
-			break;
+	case DIE_INIT_MONARCH_PROCESS:
+		if (kdump_on_init) {
+			atomic_set(&kdump_in_progress, 1);
+			*(nd->monarch_cpu) = -1;
+		}
+		break;
+	case DIE_INIT_MONARCH_LEAVE:
+		if (kdump_on_init)
+			machine_kdump_on_init();
+		break;
+	case DIE_INIT_SLAVE_LEAVE:
+		if (atomic_read(&kdump_in_progress))
+			unw_init_running(kdump_cpu_freeze, NULL);
+		break;
+	case DIE_MCA_RENDZVOUS_LEAVE:
+		if (atomic_read(&kdump_in_progress))
+			unw_init_running(kdump_cpu_freeze, NULL);
+		break;
+	case DIE_MCA_MONARCH_LEAVE:
+		/* die_register->signr indicate if MCA is recoverable */
+		if (kdump_on_fatal_mca && !args->signr) {
+			atomic_set(&kdump_in_progress, 1);
+			*(nd->monarch_cpu) = -1;
+			machine_kdump_on_init();
+		}
+		break;
 	}
 	return NOTIFY_DONE;
 }
