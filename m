From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 15 Mar 2002 02:53:13 +0000
Subject: [Linux-ia64] mkswap.c ia64 fix take 2 [patch]
Message-Id: <marc-linux-ia64-105590701905291@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Package: util-linux
Version: 2.11n-4

Hi,
	My previous patch had the wrong (too small) an upper limit on
the size of allowable swapspace. The appended patch fixes that
problem.  Now it's up to the kernel to reject too large a swap area
(it doesn't look easy to know how much kernel memory is available for
allocating a swap map).  Thanks to David Mossberger for reviewing the
original patch.


--- util-linux-2.11n/disk-utils/mkswap.c.orig	Thu Mar 15 21:09:57 2001
+++ util-linux-2.11n/disk-utils/mkswap.c	Fri Mar 15 13:40:49 2002
@@ -238,6 +238,12 @@
 #define V1_MAX_PAGES           ((1 << 17) - 1)
 #elif defined(__sparc__)
 #define V1_MAX_PAGES           (is_sparc64() ? ((3 << 29) - 1) : ((1 << 18) - 1))
+#elif defined(__ia64__)
+/* 
+ * The actual size will depend on the amount of virtual address space
+ * available to vmalloc the swap map.
+ */
+#define V1_MAX_PAGES	       ((1UL << 54) - 1)
 #else
 #define V1_MAX_PAGES           V1_OLD_MAX_PAGES
 #endif
@@ -373,7 +379,7 @@
 }
 
 static long
-valid_offset (int fd, int offset) {
+valid_offset (int fd, off_t offset) {
 	char ch;
 
 	if (lseek (fd, offset, 0) < 0)
@@ -383,16 +389,16 @@
 	return 1;
 }
 
-static int
+static off_t
 find_size (int fd) {
-	unsigned int high, low;
+	off_t high, low;
 
 	low = 0;
 	for (high = 1; high > 0 && valid_offset (fd, high); high *= 2)
 		low = high;
 	while (low < high - 1)
 	{
-		const int mid = (low + high) / 2;
+		const off_t mid = (low + high) / 2;
 
 		if (valid_offset (fd, mid))
 			low = mid;
@@ -432,9 +438,9 @@
 main(int argc, char ** argv) {
 	struct stat statbuf;
 	int i, sz;
-	int maxpages;
-	int goodpages;
-	int offset;
+	long maxpages;
+	long goodpages;
+	off_t offset;
 	int force = 0;
 	char *block_count = 0;
 	char *pp;
@@ -604,7 +610,7 @@
 	if (goodpages <= 0)
 		die(_("Unable to set up swap-space: unreadable"));
 	printf(_("Setting up swapspace version %d, size = %ld bytes\n"),
-		version, (long)(goodpages*pagesize));
+		version, (unsigned long)goodpages * pagesize);
 	write_signature((version = 0) ? "SWAP-SPACE" : "SWAPSPACE2");
 
 	offset = ((version = 0) ? 0 : 1024);

