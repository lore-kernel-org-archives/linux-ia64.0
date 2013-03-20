From: Richard Weinberger <richard@nod.at>
Date: Wed, 20 Mar 2013 11:06:59 +0000
Subject: [PATCH] IA64: Fix stack overflow in create_palinfo_proc_entries
Message-Id: <1363777619-15830-1-git-send-email-richard@nod.at>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Richard Weinberger <richard@nod.at>

Having more than 99 CPUs causes an overflow of cpustr.
If an attacker is able to control the number CPUs he might able to inject code
...kind of. ;-)

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 arch/ia64/kernel/palinfo.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index 77597e5..35bee152 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -971,20 +971,18 @@ palinfo_read_entry(char *page, char **start, off_t off, int count, int *eof, voi
 static void __cpuinit
 create_palinfo_proc_entries(unsigned int cpu)
 {
-#	define CPUSTR	"cpu%d"
-
 	pal_func_cpu_u_t f;
 	struct proc_dir_entry **pdir;
 	struct proc_dir_entry *cpu_dir;
 	int j;
-	char cpustr[sizeof(CPUSTR)];
+	char cpustr[32];
 
 
 	/*
 	 * we keep track of created entries in a depth-first order for
 	 * cleanup purposes. Each entry is stored into palinfo_proc_entries
 	 */
-	sprintf(cpustr,CPUSTR, cpu);
+	snprintf(cpustr, sizeof(cpustr), "cpu%d", cpu);
 
 	cpu_dir = proc_mkdir(cpustr, palinfo_dir);
 
-- 
1.8.1.4

