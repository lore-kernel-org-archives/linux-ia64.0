From: Pat Gefre <pfg@sgi.com>
Date: Tue, 30 Mar 2004 23:24:36 +0000
Subject: [PATCH 2.6] small Altix interface.c patch
Message-Id: <200403302324.i2UNObMT153350@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A small mod to:

Change the calls to link_path_walk() to path_walk().  link_path_walk()
doesn't initialze current->total_link_count and path_walk() does.
Without the initialization, path_walks start to fail when 40 sym links
have been followed.

-- Pat

Patrick Gefre
Silicon Graphics, Inc.                     (E-Mail)  pfg@sgi.com
2750 Blue Water Rd                         (Voice)   (651) 683-3127
Eagan, MN 55121-1400                       (FAX)     (651) 683-3054




--- linux.base/arch/ia64/sn/io/hwgfs/interface.c	2004-03-10 20:55:51.000000000 -0600
+++ linux/arch/ia64/sn/io/hwgfs/interface.c	2004-03-30 10:56:18.000000000 -0600
@@ -36,7 +36,7 @@
 		memcpy(buf, *path, len);
 		buf[len] = '\0';
 
-		error = link_path_walk(buf, nd); 
+		error = path_walk(buf, nd); 
 		if (unlikely(error))
 			return error;
 
@@ -83,7 +83,7 @@
 	if (unlikely(error))
 		return error;
 
-	error = link_path_walk(name, &nd);
+	error = path_walk(name, &nd);
 	if (unlikely(error))
 		return error;
 
@@ -274,7 +274,7 @@
 	nd.dentry = dget(base ? base : hwgfs_vfsmount->mnt_sb->s_root);
 	nd.flags = (traverse_symlinks ? LOOKUP_FOLLOW : 0);
 
-	error = link_path_walk(name, &nd);
+	error = path_walk(name, &nd);
 	if (likely(!error)) {
 		dentry = nd.dentry;
 		path_release(&nd);		/* stale data from here! */
