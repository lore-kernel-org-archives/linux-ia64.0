From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 01 Sep 2000 04:49:16 +0000
Subject: Re: [Linux-ia64] new toolchain snapshots
Message-Id: <marc-linux-ia64-105590678205438@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205422@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205422@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 30 Aug 2000 16:54:29 -0700, 
Jim Wilson <wilson@cygnus.com> wrote:
>I am making available new toolchain snapshots, based on July FSF gcc sources.
>These snapshots are available from ftp.cygnus.com in pub/ia64-linux.  The
>current snapshot is in the snap-000828 directory.

Compiling the 2.4.0-test7 code for fs/nfs/dir.c with this snapshot
generates an unresolved reference to __multi3, for no reason that I can
see.  The strange thing is that nm shows the unresolved reference but
objdump -r does not list it.  BTW, I applied the glibc 2.1.3 patch.

This patch stops the toolchain snapshot generating the reference to
__multi3.  Damned if I know why it works but it does.

Index: 0-test7.6/fs/nfs/dir.c
--- 0-test7.6/fs/nfs/dir.c Thu, 24 Aug 2000 03:29:10 +1000 kaos (linux-2.4/h/b/37_dir.c 1.1.1.4 644)
+++ 0-test7.6(w)/fs/nfs/dir.c Fri, 01 Sep 2000 15:43:21 +1100 kaos (linux-2.4/h/b/37_dir.c 1.1.1.4 644)
@@ -807,7 +807,7 @@ static int nfs_sillyrename(struct inode 
 	static unsigned int sillycounter = 0;
 	const int      i_inosize  = sizeof(dir_i->i_ino)*2;
 	const int      countersize = sizeof(sillycounter)*2;
-	const int      slen       = strlen(".nfs") + i_inosize + countersize;
+	const int      slen       = 4 + i_inosize + countersize;
 	char           silly[slen+1];
 	struct qstr    qsilly;
 	struct dentry *sdentry;


