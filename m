From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 19 Dec 2004 05:24:53 +0000
Subject: [PATCH] Perfmon over-initialises its inodes
Message-Id: <20041219052453.GC7113@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


i_sb and i_sock are both initialised by alloc_inode().

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Index: linux/arch/ia64/kernel/perfmon.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/kernel/perfmon.c,v
retrieving revision 1.20
diff -u -p -r1.20 perfmon.c
--- linux/arch/ia64/kernel/perfmon.c	4 Dec 2004 07:02:04 -0000	1.20
+++ linux/arch/ia64/kernel/perfmon.c	19 Dec 2004 05:22:28 -0000
@@ -2160,9 +2160,7 @@ pfm_alloc_fd(struct file **cfile)
 
 	DPRINT(("new inode ino=%ld @%p\n", inode->i_ino, inode));
 
-	inode->i_sb   = pfmfs_mnt->mnt_sb;
 	inode->i_mode = S_IFCHR|S_IRUGO;
-	inode->i_sock = 0;
 	inode->i_uid  = current->fsuid;
 	inode->i_gid  = current->fsgid;
 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
