From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Apr 2003 00:14:00 +0000
Subject: [Linux-ia64] one-liner to improve 2.5.67 stability
Message-Id: <marc-linux-ia64-105590723705526@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm still waiting for confirmation, but the attached patch clearly and
greatly improved long-term stability of 2.5.67 for me.  Without the
patch, 2.5.67 would seemingly randomly get stuck occasionally (usually
only when working remotely, from home).  I won't claim victory just
yet, but with this patch in, 2.5.67 has been running all day without
any apparent problems so far.  And with Arun's x86 patch, even ia32
binaries work fine again.  2.5 is starting to look quite good.

	--david

---
From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: fix fs->lock deadlock
Newsgroups: linux.kernel
Date: Wed, 16 Apr 2003 19:50:12 +0200
Organization: linux.* mail to news gateway

The patch below is needed to avoid a deadlock on fs->lock.  Without
the patch, if __emul_lookup_dentry() returns 0, we fail to reacquire
current->fs->lock and then go ahead to read_unlock() it anyhow.  Bad
for your health.

I believe the bug was introduced by this change set (about 9 weeks ago):

  http://linux.bkbits.net:8080/linux-2.5/diffs/fs/namei.c@1.63.1.2

	--david

=== fs/namei.c 1.69 vs edited ==--- 1.69/fs/namei.c	Wed Apr  2 22:51:31 2003
+++ edited/fs/namei.c	Wed Apr 16 10:18:40 2003
@@ -847,6 +847,7 @@
			read_unlock(&current->fs->lock);
			if (__emul_lookup_dentry(name,nd))
				return 0;
+			read_lock(&current->fs->lock);
		}
		nd->mnt = mntget(current->fs->rootmnt);
		nd->dentry = dget(current->fs->root);
