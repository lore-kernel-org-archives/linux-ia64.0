From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 11 Aug 2003 02:13:46 +0000
Subject: Kill warning in minix filesystem on 64-bit archs (2.6.0-test3)
Message-Id: <marc-linux-ia64-106056819132623@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On 64-bit architectures, ino_t is int, not long, so the attached patch
is needed to prevent a warning.

Andrew, I can't find a maintainer for the MINIX filesystem --- can you
please push this one along?


=== fs/minix/bitmap.c 1.10 vs edited ==--- 1.10/fs/minix/bitmap.c	Thu May 23 23:18:51 2002
+++ edited/fs/minix/bitmap.c	Thu Aug  7 11:56:55 2003
@@ -116,7 +116,7 @@
 
 	if (!ino || ino > sbi->s_ninodes) {
 		printk("Bad inode number on dev %s: %ld is out of range\n",
-		       sb->s_id, ino);
+		       sb->s_id, (long)ino);
 		return NULL;
 	}
 	ino--;
@@ -141,7 +141,7 @@
 	*bh = NULL;
 	if (!ino || ino > sbi->s_ninodes) {
 		printk("Bad inode number on dev %s: %ld is out of range\n",
-		       sb->s_id, ino);
+		       sb->s_id, (long)ino);
 		return NULL;
 	}
 	ino--;


--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.

