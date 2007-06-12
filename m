From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 12 Jun 2007 18:05:13 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <Pine.LNX.4.64.0706121057010.29787@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Jun 2007, Luck, Tony wrote:

> Raising the PAGE_SIZE to 64k does generate a couple of
> new warnings in the build:
> 
> drivers/usb/core/devio.c:632: warning: comparison is always false due to limited range of data type
> fs/fat/inode.c:1227: warning: comparison is always false due to limited range of data type
> 
> Both of these are due to range comparisons of u16 data types
> with PAGE_SIZE.  They both look harmless ... we'll get an
> infinitessimal performance boost from the compiler dropping
> the code, but it is annoying to add these to the (already
> large) list of warnings to ignore.
> 
> Anyone got any cute ideas on how to make these warnings
> go away?

Talk to the powerpc guys? They also support 64k page size.

The obvious solution is to put an (ugly) #ifdef around it:

Index: linux-2.6/drivers/usb/core/devio.c
=================================--- linux-2.6.orig/drivers/usb/core/devio.c	2007-06-12 10:58:57.000000000 -0700
+++ linux-2.6/drivers/usb/core/devio.c	2007-06-12 11:02:19.000000000 -0700
@@ -629,8 +629,14 @@ static int proc_control(struct dev_state
 		return -EFAULT;
 	if ((ret = check_ctrlrecip(ps, ctrl.bRequestType, ctrl.wIndex)))
 		return ret;
+#if PAGE_SIZE < 65536
+	/*
+	 * ctrl.wLength is a 16 bit value that cannot be greater
+	 * than page size if PAGE_SIZE >= 64k.
+	 */
 	if (ctrl.wLength > PAGE_SIZE)
 		return -EINVAL;
+#endif
 	if (!(tbuf = (unsigned char *)__get_free_page(GFP_KERNEL)))
 		return -ENOMEM;
 	tmo = ctrl.timeout;
Index: linux-2.6/fs/fat/inode.c
=================================--- linux-2.6.orig/fs/fat/inode.c	2007-06-12 10:59:53.000000000 -0700
+++ linux-2.6/fs/fat/inode.c	2007-06-12 11:01:17.000000000 -0700
@@ -1223,8 +1223,15 @@ int fat_fill_super(struct super_block *s
 	logical_sector_size  		le16_to_cpu(get_unaligned((__le16 *)&b->sector_size));
 	if (!is_power_of_2(logical_sector_size)
-	    || (logical_sector_size < 512)
-	    || (PAGE_CACHE_SIZE < logical_sector_size)) {
+#if PAGE_SIZE < 65536
+	/*
+	 * Logical sector size is a 16 bit value.
+	 * If the page size is 64k or higher then the comparison
+	 * is always true.
+	 */
+	    || (PAGE_CACHE_SIZE < logical_sector_size)
+#endif
+	    || (logical_sector_size < 512)) {
 		if (!silent)
 			printk(KERN_ERR "FAT: bogus logical sector size %u\n",
 			       logical_sector_size);

