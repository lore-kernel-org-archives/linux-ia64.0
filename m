From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 13 Mar 2002 23:54:21 +0000
Subject: [Linux-ia64] mkswap fails to create large swap partitions on ia64 [patch]
Message-Id: <marc-linux-ia64-105590701905268@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Package: util-linux
Version: 2.11n-4

Hi,
	Attempts to create large swap files/partitions fails on IA64,
because some things that are ints in mkswap source should be off_t or
long.

Here's a patch.


--- util-linux-2.11n/disk-utils/mkswap.c.orig	Thu Mar 15 21:09:57 2001
+++ util-linux-2.11n/disk-utils/mkswap.c	Thu Mar 14 10:52:09 2002
@@ -232,7 +232,7 @@
 /* patch from jj - why does this differ from the above? */
 /* 32bit kernels have a second limitation of 2GB, sparc64 is limited by
    the size of virtual address space allocation for vmalloc */
-#if defined(__alpha__)
+#if defined(__alpha__) || defined(__ia64__)
 #define V1_MAX_PAGES           ((1 << 24) - 1)
 #elif defined(__mips__)
 #define V1_MAX_PAGES           ((1 << 17) - 1)
@@ -373,7 +373,7 @@
 }
 
 static long
-valid_offset (int fd, int offset) {
+valid_offset (int fd, off_t offset) {
 	char ch;
 
 	if (lseek (fd, offset, 0) < 0)
@@ -383,16 +383,16 @@
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
@@ -432,9 +432,9 @@
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
@@ -604,7 +604,7 @@
 	if (goodpages <= 0)
 		die(_("Unable to set up swap-space: unreadable"));
 	printf(_("Setting up swapspace version %d, size = %ld bytes\n"),
-		version, (long)(goodpages*pagesize));
+		version, (unsigned long)goodpages * pagesize);
 	write_signature((version = 0) ? "SWAP-SPACE" : "SWAPSPACE2");
 
 	offset = ((version = 0) ? 0 : 1024);

