From: Andreas Schwab <schwab@suse.de>
Date: Mon, 04 Aug 2003 19:18:57 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106002479508999@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

jbarnes@sgi.com (Jesse Barnes) writes:

|> diff -Nru a/fs/xfs/linux/xfs_vfs.h b/fs/xfs/linux/xfs_vfs.h
|> --- a/fs/xfs/linux/xfs_vfs.h	Wed Jul 16 12:10:39 2003
|> +++ b/fs/xfs/linux/xfs_vfs.h	Wed Jul 16 12:10:39 2003
|> @@ -44,8 +44,8 @@
|> =20
|>  typedef struct vfs {
|>  	u_int			vfs_flag;	/* flags */
|> -	fsid_t			vfs_fsid;	/* file system ID */
|> -	fsid_t			*vfs_altfsid;	/* An ID fixed for life of FS */
|> +	__kernel_fsid_t			vfs_fsid;	/* file system ID */
|> +	__kernel_fsid_t			*vfs_altfsid;	/* An ID fixed for life of FS */
|>  	bhv_head_t		vfs_bh;		/* head of vfs behavior chain */
|>  	struct super_block	*vfs_super;	/* Linux superblock structure */
|>  	struct task_struct	*vfs_sync_task;

Alternatively you could use this patch (following the other
architectures):

--- linux-2.5.73/include/asm-ia64/statfs.h.~1~	2003-06-22 20:32:55.00000000=
0 +0200
+++ linux-2.5.73/include/asm-ia64/statfs.h	2003-07-01 16:14:44.000000000 +0=
200
@@ -6,6 +6,11 @@
  * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
+#ifndef __KERNEL_STRICT_NAMES
+# include <linux/types.h>
+typedef __kernel_fsid_t	fsid_t;
+#endif
+
 /*
  * This is ugly --- we're already 64-bit, so just duplicate the definitions
  */

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
