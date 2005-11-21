From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 21 Nov 2005 18:00:38 +0000
Subject: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch to prevent sn2_ptc_init code from attempting to load on non-sn2 systems
when sn2_smp.c is built-in to kernel.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -492,6 +492,9 @@ static struct proc_dir_entry *proc_sn2_p
 
 static int __init sn2_ptc_init(void)
 {
+	if (!ia64_platform_is("sn2"))
+		return -ENOSYS;
+
 	if (!(proc_sn2_ptc = create_proc_entry(PTC_BASENAME, 0444, NULL))) {
 		printk(KERN_ERR "unable to create %s proc entry", PTC_BASENAME);
 		return -EINVAL;
