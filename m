From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Wed, 27 Jun 2001 18:10:25 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.5)
Message-Id: <marc-linux-ia64-105590693005786@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I appled that to a Linus 2.4.5 tree, but it doesn't compile with
> devfs enabled but dev/guid disabled.  fs/partitions/check.c:522
> has an unprotected call to free_disk_guids().

I am sorry. The patch is almost too trivial to post it here, but may
still save people time:

--- 2.4.5mw/fs/partitions/check.c~	Wed Jun 27 12:36:18 2001
+++ 2.4.5mw/fs/partitions/check.c	Wed Jun 27 21:53:10 2001
@@ -519,7 +519,9 @@
 	if (unregister) {
 		devfs_unregister (dev->part[minor].de);
 		dev->part[minor].de = NULL;
+#ifdef CONFIG_DEVFS_GUID
 		free_disk_guids (dev, minor);
+#endif
 	}
 #endif  /*  CONFIG_DEVFS_FS  */
 }

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113





