From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 14 Apr 2006 00:49:07 +0000
Subject: Re: [PATCH 5/8] IA64 various hugepage size - mount more hugetlb fs
Message-Id: <1144975746.5817.94.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1144974367.5817.39.camel@linux-znh>
	 <1144974667.5817.51.camel@linux-znh>  <1144974881.5817.59.camel@linux-znh>
	 <1144975292.5817.74.camel@linux-znh>  <1144975523.5817.84.camel@linux-znh>
In-Reply-To: <1144975523.5817.84.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-IA64 <linux-ia64@vger.kernel.org>, Tony <tony.luck@intel.com>, Kenneth W <kenneth.w.chen@intel.com>

Mount more hugetlbfs for SHM to support various hugepage size
in SHM.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
--- a/fs/hugetlbfs/inode.c	2006-04-12 10:15:03.000000000 +0800
+++ b/fs/hugetlbfs/inode.c	2006-04-12 10:17:23.000000000 +0800
@@ -759,7 +759,7 @@ static struct file_system_type hugetlbfs
 	.kill_sb	= kill_litter_super,
 };
 
-static struct vfsmount *hugetlbfs_vfsmount;
+static struct vfsmount *hugetlbfs_vfsmount[MAX_ORDER];
 
 static int can_do_hugetlb_shm(void)
 {
@@ -784,7 +784,7 @@ struct file *hugetlb_zero_setup(size_t s
 	if (!user_shm_lock(size, current->user))
 		return ERR_PTR(-ENOMEM);
 
-	root = hugetlbfs_vfsmount->mnt_root;
+	root = hugetlbfs_vfsmount[order]->mnt_root;
 	snprintf(buf, 16, "%u", atomic_inc_return(&counter));
 	quick_string.name = buf;
 	quick_string.len = strlen(quick_string.name);
@@ -812,7 +812,7 @@ struct file *hugetlb_zero_setup(size_t s
 	d_instantiate(dentry, inode);
 	inode->i_size = size;
 	inode->i_nlink = 0;
-	file->f_vfsmnt = mntget(hugetlbfs_vfsmount);
+	file->f_vfsmnt = mntget(hugetlbfs_vfsmount[order]);
 	file->f_dentry = dentry;
 	file->f_mapping = inode->i_mapping;
 	file->f_op = &hugetlbfs_file_operations;
@@ -834,27 +834,49 @@ static int __init init_hugetlbfs_fs(void
 {
 	int error;
 	struct vfsmount *vfsmount;
-
 	hugetlbfs_inode_cachep = kmem_cache_create("hugetlbfs_inode_cache",
-					sizeof(struct hugetlbfs_inode_info),
-					0, 0, init_once, NULL);
+			sizeof(struct hugetlbfs_inode_info),
+			0, 0, init_once, NULL);
 	if (hugetlbfs_inode_cachep = NULL)
 		return -ENOMEM;
 
 	error = register_filesystem(&hugetlbfs_fs_type);
 	if (error)
 		goto out;
-
-	vfsmount = kern_mount(&hugetlbfs_fs_type);
-
-	if (!IS_ERR(vfsmount)) {
-		hugetlbfs_vfsmount = vfsmount;
-		return 0;
+#ifdef ARCH_HAS_VARIABLE_HUGEPAGE_SIZE
+	{
+		int order;
+		char fsname[64], data[64];
+		for (order = 0; order < MAX_ORDER; order++) {
+			if (is_valid_hpage_size(1UL<<(PAGE_SHIFT+order))) {
+				sprintf(fsname, "%s%d", hugetlbfs_fs_type.name, order);
+				sprintf(data, "page_size=%ld", (1UL<<(PAGE_SHIFT+order)));
+				vfsmount = do_kern_mount(hugetlbfs_fs_type.name, 0,
+						fsname, data);
+
+				if (!IS_ERR(vfsmount))
+					hugetlbfs_vfsmount[order] = vfsmount;
+				else {
+					error = PTR_ERR(vfsmount);
+					goto out;
+				}
+			}
+		}
 	}
+#else
+        vfsmount = kern_mount(&hugetlbfs_fs_type);
 
-	error = PTR_ERR(vfsmount);
+        if (!IS_ERR(vfsmount)) {
+                hugetlbfs_vfsmount[HUGETLB_INIT_PAGE_ORDER] = vfsmount;
+                return 0;
+        }
+
+        error = PTR_ERR(vfsmount);
+        goto out;
+#endif
+	return 0;
 
- out:
+out:
 	if (error)
 		kmem_cache_destroy(hugetlbfs_inode_cachep);
 	return error;


