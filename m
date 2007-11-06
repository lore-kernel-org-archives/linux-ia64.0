From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Nov 2007 19:59:55 +0000
Subject: sysctl table check failed ... Writable sysctl directory
Message-Id: <617E1C2C70743745A92448908E030B2A02E21EDD@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane,

For a couple of weeks now the kernel has been complaining about
a couple of "Writable sysctl directories".  When I pulled from
Linus latest git tree today, the complaint got louder with an
added stack trace ... pointing at pfm_init().

This patch fixes the complaint.  Did you need mode 0755 for
some reason, or should I just apply this?

-Tony

---

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 59169bf..73e7c2e 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -558,7 +558,7 @@ static ctl_table pfm_sysctl_dir[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "perfmon",
-		.mode		= 0755,
+		.mode		= 0555,
 		.child		= pfm_ctl_table,
 	},
  	{}
@@ -567,7 +567,7 @@ static ctl_table pfm_sysctl_root[] = {
 	{
 		.ctl_name	= CTL_KERN,
 		.procname	= "kernel",
-		.mode		= 0755,
+		.mode		= 0555,
 		.child		= pfm_sysctl_dir,
 	},
  	{}
