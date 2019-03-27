From: David Howells <dhowells@redhat.com>
Date: Wed, 27 Mar 2019 23:42:26 +0000
Subject: [RFC PATCH 15/68] vfs: Convert ia64 perfmon to use the new mount API
Message-Id: <155373014602.7602.12063170296510196444.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
In-Reply-To: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: viro@zeniv.linux.org.uk
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, dhowells@redhat.com

Convert the ia64 perfmon filesystem to the new internal mount API as the old
one will be obsoleted and removed.  This allows greater flexibility in
communication of mount parameters between userspace, the VFS and the
filesystem.

See Documentation/filesystems/mount_api.txt for more information.

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
 
