From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 14 Apr 2006 00:41:32 +0000
Subject: Re: [PATCH 3/8] IA64 various hugepage size - Add a mount option to
Message-Id: <1144975292.5817.74.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1144974367.5817.39.camel@linux-znh>
	 <1144974667.5817.51.camel@linux-znh>  <1144974881.5817.59.camel@linux-znh>
In-Reply-To: <1144974881.5817.59.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-IA64 <linux-ia64@vger.kernel.org>, Tony <tony.luck@intel.com>, Kenneth W <kenneth.w.chen@intel.com>

Add a mount option page_size= to hugetlbfs.
The s_blocksize_bits in hugetlb super block will indicate the huge page size which attached 
to this fs.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
--- a/fs/hugetlbfs/inode.c	2006-04-11 08:51:59.000000000 +0800
+++ b/fs/hugetlbfs/inode.c	2006-04-11 10:55:49.000000000 +0800
@@ -63,6 +63,14 @@ static int hugetlbfs_file_mmap(struct fi
 	loff_t len, vma_len;
 	int ret;
 
+#ifdef ARCH_HAS_VARIABLE_HUGEPAGE_SIZE
+        struct super_block *sb = inode->i_sb;
+        unsigned long hpage_shift = sb->s_blocksize_bits;
+
+        if (hpage_shift != vma->vm_mm->hugepage_shift)
+                return -EINVAL;
+#endif
+
 	if (vma->vm_pgoff & (HPAGE_SIZE / PAGE_SIZE - 1))
 		return -EINVAL;
 
@@ -632,7 +640,17 @@ hugetlbfs_parse_options(char *options, s
 			size &= HPAGE_MASK;
 			pconfig->nr_blocks = (size >> HPAGE_SHIFT);
 			value = rest;
-		} else if (!strcmp(opt,"nr_inodes")) {
+		}
+#ifdef ARCH_HAS_VARIABLE_HUGEPAGE_SIZE
+                else if (!strcmp(opt, "page_size")) {
+                        unsigned long long size = memparse(value, &rest);
+                        if (!is_valid_hpage_size(size))
+                                return -EINVAL;
+                        pconfig->page_shift = __ffs(size);
+                        value = rest;
+                }
+#endif
+		else if (!strcmp(opt,"nr_inodes")) {
 			pconfig->nr_inodes = memparse(value, &rest);
 			value = rest;
 		} else
@@ -658,6 +676,7 @@ hugetlbfs_fill_super(struct super_block 
 	config.uid = current->fsuid;
 	config.gid = current->fsgid;
 	config.mode = 0755;
+	config.page_shift = HPAGE_SHIFT;
 	ret = hugetlbfs_parse_options(data, &config);
 
 	if (ret)
@@ -673,8 +692,8 @@ hugetlbfs_fill_super(struct super_block 
 	sbinfo->max_inodes = config.nr_inodes;
 	sbinfo->free_inodes = config.nr_inodes;
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-	sb->s_blocksize = HPAGE_SIZE;
-	sb->s_blocksize_bits = HPAGE_SHIFT;
+	sb->s_blocksize = 1UL << config.page_shift;
+	sb->s_blocksize_bits = config.page_shift;
 	sb->s_magic = HUGETLBFS_MAGIC;
 	sb->s_op = &hugetlbfs_ops;
 	sb->s_time_gran = 1;
diff -Nraup a/include/linux/hugetlb.h b/include/linux/hugetlb.h
--- a/include/linux/hugetlb.h	2006-04-11 08:52:00.000000000 +0800
+++ b/include/linux/hugetlb.h	2006-04-11 10:51:41.000000000 +0800
@@ -124,6 +124,7 @@ struct hugetlbfs_config {
 	uid_t   uid;
 	gid_t   gid;
 	umode_t mode;
+	int     page_shift;
 	long	nr_blocks;
 	long	nr_inodes;
 };

