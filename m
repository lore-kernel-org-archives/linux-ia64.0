From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Wed, 17 Jun 2020 20:12:14 +0000
Subject: [PATCH] ia64: Fix a typo in a comment
Message-Id: <20200617201214.733262-1-christophe.jaillet@wanadoo.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, walken@google.com, vbabka@suse.cz, tglx@linutronix.de, namit@vmware.com, afzal.mohd.ma@gmail.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>

s/permfon/perfmon/

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 arch/ia64/kernel/perfmon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 971f166873aa..e8e30a408946 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -4555,7 +4555,7 @@ pfm_exit_thread(struct task_struct *task)
 }
 
 /*
- * functions MUST be listed in the increasing order of their index (see permfon.h)
+ * functions MUST be listed in the increasing order of their index (see perfmon.h)
  */
 #define PFM_CMD(name, flags, arg_count, arg_type, getsz) { name, #name, flags, arg_count, sizeof(arg_type), getsz }
 #define PFM_CMD_S(name, flags) { name, #name, flags, 0, 0, NULL }
-- 
2.25.1
