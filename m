From: Joe Perches <joe@perches.com>
Date: Fri, 14 Jun 2013 02:37:28 +0000
Subject: [Trivial PATCH 03/33] ia64: crash: Convert use of typedef ctl_table to struct ctl_table
Message-Id: <6b052bed2e582dd6565311829a9c99473c083c5e.1371177118.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1371177118.git.joe@perches.com>
In-Reply-To: <cover.1371177118.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <trivial@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This typedef is unnecessary and should just be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/crash.c   | 4 ++--
 arch/ia64/kernel/perfmon.c | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index b942f40..2955f35 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -237,7 +237,7 @@ kdump_init_notifier(struct notifier_block *self, unsigned long val, void *data)
 }
 
 #ifdef CONFIG_SYSCTL
-static ctl_table kdump_ctl_table[] = {
+static struct ctl_table kdump_ctl_table[] = {
 	{
 		.procname = "kdump_on_init",
 		.data = &kdump_on_init,
@@ -255,7 +255,7 @@ static ctl_table kdump_ctl_table[] = {
 	{ }
 };
 
-static ctl_table sys_table[] = {
+static struct ctl_table sys_table[] = {
 	{
 	  .procname = "kernel",
 	  .mode = 0555,
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 5a9ff1c..81c962b 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -521,7 +521,7 @@ static pmu_config_t		*pmu_conf;
 pfm_sysctl_t pfm_sysctl;
 EXPORT_SYMBOL(pfm_sysctl);
 
-static ctl_table pfm_ctl_table[]={
+static struct ctl_table pfm_ctl_table[] = {
 	{
 		.procname	= "debug",
 		.data		= &pfm_sysctl.debug,
@@ -552,7 +552,7 @@ static ctl_table pfm_ctl_table[]={
 	},
 	{}
 };
-static ctl_table pfm_sysctl_dir[] = {
+static struct ctl_table pfm_sysctl_dir[] = {
 	{
 		.procname	= "perfmon",
 		.mode		= 0555,
@@ -560,7 +560,7 @@ static ctl_table pfm_sysctl_dir[] = {
 	},
  	{}
 };
-static ctl_table pfm_sysctl_root[] = {
+static struct ctl_table pfm_sysctl_root[] = {
 	{
 		.procname	= "kernel",
 		.mode		= 0555,
-- 
1.8.1.2.459.gbcd45b4.dirty

