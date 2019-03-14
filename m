From: David Howells <dhowells@redhat.com>
Date: Thu, 14 Mar 2019 16:10:32 +0000
Subject: [PATCH 12/38] vfs: Convert ia64 perfmon to fs_context
Message-Id: <155257983288.13720.10412307262671159711.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <155257972443.13720.11743171471060355965.stgit@warthog.procyon.org.uk>
In-Reply-To: <155257972443.13720.11743171471060355965.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: viro@zeniv.linux.org.uk
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, dhowells@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Tony Luck <tony.luck@intel.com>
cc: Fenghua Yu <fenghua.yu@intel.com>
cc: linux-ia64@vger.kernel.org
---

 arch/ia64/kernel/perfmon.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 7a969f4c3534..4b5770736ac5 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -38,6 +38,7 @@
 #include <linux/smp.h>
 #include <linux/pagemap.h>
 #include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/bitops.h>
 #include <linux/capability.h>
 #include <linux/rcupdate.h>
@@ -599,17 +600,16 @@ pfm_unprotect_ctx_ctxsw(pfm_context_t *x, unsigned long f)
 /* forward declaration */
 static const struct dentry_operations pfmfs_dentry_operations;
 
-static struct dentry *
-pfmfs_mount(struct file_system_type *fs_type, int flags, const char *dev_name, void *data)
+static int pfmfs_init_fs_context(struct fs_context *fc)
 {
-	return mount_pseudo(fs_type, "pfm:", NULL, &pfmfs_dentry_operations,
-			PFMFS_MAGIC);
+	return vfs_init_pseudo_fs_context(fc, "pfm:", NULL, NULL,
+					  &pfmfs_dentry_operations, PFMFS_MAGIC);
 }
 
 static struct file_system_type pfm_fs_type = {
-	.name     = "pfmfs",
-	.mount    = pfmfs_mount,
-	.kill_sb  = kill_anon_super,
+	.name			= "pfmfs",
+	.init_fs_context	= pfmfs_init_fs_context,
+	.kill_sb		= kill_anon_super,
 };
 MODULE_ALIAS_FS("pfmfs");
 
