From: j-nomura@ce.jp.nec.com
Date: Thu, 27 Dec 2001 08:09:30 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.17)
Message-Id: <marc-linux-ia64-105590698805718@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> The ia64 patch for v2.4.17 is now at
> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:

I had to apply the patch below to compile with CONFIG_DEVFS_GUID.

Index: fs/devfs/base.c
=================================RCS file: /home/cvsadm/cvsroot/linux/fs/devfs/base.c,v
retrieving revision 1.1.1.16.2.1
diff -u -r1.1.1.16.2.1 base.c
--- fs/devfs/base.c	2001/12/27 07:21:15	1.1.1.16.2.1
+++ fs/devfs/base.c	2001/12/27 07:53:18
@@ -2186,7 +2186,7 @@
 	slave = master->slave;
 	if (slave) {
 		master->slave = NULL;
-		unregister (slave);
+		unregister (slave->parent, slave);
 	};
 }
 #endif /* CONFIG_DEVFS_GUID */

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.

