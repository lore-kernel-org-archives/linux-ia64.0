From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 20 Oct 2003 17:42:26 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106667188118697@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 17 October 2003 5:55 pm, Andrew Morton wrote:
> Still, the code you have is quite reasonable.  But please structure it
> thusly:
> ...

Here's a patch structured that way.

> As for return values: if the requested read or write starts at a
> not-present address it should probably return -EFAULT.  This is what ia32
> will do.  Arguably this is indistinguishable from a bad address on the
> userspace side and we should return -EINVAL but whatever.

I made it return -EFAULT.  I worry a little bit because ia32
returned 0 (short read) when (addr >= high_memory) before,
but I don't have a strong opinion one way or the other.

=== drivers/char/mem.c 1.44 vs edited ==--- 1.44/drivers/char/mem.c	Sun Sep 21 15:50:34 2003
+++ edited/drivers/char/mem.c	Mon Oct 20 10:43:08 2003
@@ -79,6 +79,22 @@
 #endif
 }
 
+#ifndef ARCH_HAS_VALID_PHYS_ADDR_RANGE
+static inline int valid_phys_addr_range(unsigned long addr, size_t *count)
+{
+	unsigned long end_mem;
+
+	end_mem = __pa(high_memory);
+	if (addr >= end_mem)
+		return 0;
+
+	if (*count > end_mem - addr)
+		*count = end_mem - addr;
+
+	return 1;
+}
+#endif
+
 static ssize_t do_write_mem(struct file * file, void *p, unsigned long realp,
 			    const char * buf, size_t count, loff_t *ppos)
 {
@@ -113,14 +129,10 @@
 			size_t count, loff_t *ppos)
 {
 	unsigned long p = *ppos;
-	unsigned long end_mem;
 	ssize_t read;
 
-	end_mem = __pa(high_memory);
-	if (p >= end_mem)
-		return 0;
-	if (count > end_mem - p)
-		count = end_mem - p;
+	if (!valid_phys_addr_range(p, &count))
+		return -EFAULT;
 	read = 0;
 #if defined(__sparc__) || (defined(__mc68000__) && defined(CONFIG_MMU))
 	/* we don't have page 0 mapped on sparc and m68k.. */
@@ -149,13 +161,9 @@
 			 size_t count, loff_t *ppos)
 {
 	unsigned long p = *ppos;
-	unsigned long end_mem;
 
-	end_mem = __pa(high_memory);
-	if (p >= end_mem)
-		return 0;
-	if (count > end_mem - p)
-		count = end_mem - p;
+	if (!valid_phys_addr_range(p, &count))
+		return -EFAULT;
 	return do_write_mem(file, __va(p), p, buf, count, ppos);
 }
 

