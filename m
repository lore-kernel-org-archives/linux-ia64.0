From: Alexey Dobriyan <adobriyan@openvz.org>
Date: Tue, 23 Jan 2007 15:57:53 +0000
Subject: [PATCH 2/2] ia64: wire up pselect, ppoll
Message-Id: <20070123160408.GB11114@localhost.sw.ru>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[PATCH] ia64: wire up pselect, ppoll

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-off-by: Alexey Dobriyan <adobriyan@openvz.org>
---

 arch/ia64/kernel/entry.S |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1575,8 +1575,8 @@ sys_call_table:
 	data8 sys_readlinkat
 	data8 sys_fchmodat
 	data8 sys_faccessat
-	data8 sys_ni_syscall			// reserved for pselect
-	data8 sys_ni_syscall			// 1295 reserved for ppoll
+	data8 sys_pselect6
+	data8 sys_ppoll
 	data8 sys_unshare
 	data8 sys_splice
 	data8 sys_set_robust_list

