From: Jack Steiner <steiner@sgi.com>
Date: Fri, 30 Mar 2001 17:16:23 +0000
Subject: [Linux-ia64] 64K pagesize - patch to make swapping work
Message-Id: <marc-linux-ia64-105590693005372@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a patch to make swapping work on IA64 systems with
64K pages. 

The patch fixes a problem that occurs in the use of the b_size
field in the buffer_head struct. This field is defined as a short.
If a 64k page is swapped to a device, the swap code writes 64K blocks
& overflows this field. (I assume that changing b_size to an
"int" is a bad idea).

Fortunately, the infrastructure was already in place to
handle this case since swapping to files hits a similar problem in
that the page size may be bigger than the file block size.


We are continuing testing with 64K pages. Most of the regression base
has passed but we took at least one ugly crash that may be related
to large pages.




diff -Naur linux_base/include/linux/swap.h linux/include/linux/swap.h
--- linux_base/include/linux/swap.h	Sat Mar 24 22:52:24 2001
+++ linux/include/linux/swap.h	Mon Mar 26 11:51:39 2001
@@ -10,6 +10,8 @@
 
 #define MAX_SWAPFILES 8
 
+#define MAX_SWAPDEV_BLKSIZE	32768	/* limited by b_size in buffer_head */
+
 union swap_header {
 	struct 
 	{
diff -Naur linux_base/mm/page_io.c linux/mm/page_io.c
--- linux_base/mm/page_io.c	Thu Mar 15 08:26:49 2001
+++ linux/mm/page_io.c	Sat Mar 24 21:14:38 2001
@@ -55,9 +55,17 @@
 
 	get_swaphandle_info(entry, &offset, &dev, &swapf);
 	if (dev) {
-		zones[0] = offset;
-		zones_used = 1;
-		block_size = PAGE_SIZE;
+		if (PAGE_SIZE > MAX_SWAPDEV_BLKSIZE) {
+			int	i;
+			for (i=0; i<PAGE_SIZE/MAX_SWAPDEV_BLKSIZE; i++)
+				zones[i] = (PAGE_SIZE/MAX_SWAPDEV_BLKSIZE) * offset + i;
+			zones_used = i;
+			block_size = MAX_SWAPDEV_BLKSIZE;
+		} else {
+			zones[0] = offset;
+			zones_used = 1;
+			block_size = PAGE_SIZE;
+		}
 	} else if (swapf) {
 		int i, j;
 		unsigned int block = offset
diff -Naur linux_base/mm/swapfile.c linux/mm/swapfile.c
--- linux_base/mm/swapfile.c	Thu Mar 15 08:26:49 2001
+++ linux/mm/swapfile.c	Sat Mar 24 20:53:53 2001
@@ -597,11 +597,13 @@
 	error = -EINVAL;
 
 	if (S_ISBLK(swap_inode->i_mode)) {
+		int	block_size;
 		kdev_t dev = swap_inode->i_rdev;
 		struct block_device_operations *bdops;
 
 		p->swap_device = dev;
-		set_blocksize(dev, PAGE_SIZE);
+		block_size =  (PAGE_SIZE < MAX_SWAPDEV_BLKSIZE) ? PAGE_SIZE : MAX_SWAPDEV_BLKSIZE;
+		set_blocksize(dev, block_size);
 		
 		bdev = swap_inode->i_bdev;
 		bdops = devfs_get_ops(devfs_get_handle_from_inode(swap_inode));
@@ -610,7 +612,7 @@
 		error = blkdev_get(bdev, FMODE_READ|FMODE_WRITE, 0, BDEV_SWAP);
 		if (error)
 			goto bad_swap_2;
-		set_blocksize(dev, PAGE_SIZE);
+		set_blocksize(dev, block_size);
 		error = -ENODEV;
 		if (!dev || (blk_size[MAJOR(dev)] &&
 		     !blk_size[MAJOR(dev)][MINOR(dev)]))
-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


