From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 28 Jul 2006 14:01:50 +0000
Subject: [PATCH 1/2] Fix RAID5 components
Message-Id: <20060728140150.9149.72072.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060728140145.9149.43458.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20060728140145.9149.43458.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-scsi@vger.kernel.org
Cc: Prarit Bhargava <prarit@sgi.com>

Patch to fix export issue with RAID5 + IA64.

	-adds new MD_RAID5_IA64 option (default to "y")
	 that builds IA64 RAID5 components.

This patch should be committed by the MD maintainers.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff -urNp linux-2.6.17.ia64.orig/drivers/md/Kconfig linux-2.6.17.ia64/drivers/md/Kconfig
--- linux-2.6.17.ia64.orig/drivers/md/Kconfig	2006-07-27 09:20:03.000000000 -0400
+++ linux-2.6.17.ia64/drivers/md/Kconfig	2006-07-27 14:55:15.000000000 -0400
@@ -135,6 +135,13 @@ config MD_RAID456
 
 	  If unsure, say Y.
 
+config MD_RAID5_IA64
+	bool "RAID 5 support for IA64"
+	depends on MD_RAID456 && IA64
+	default y
+	---help---
+	Say "Y" if you plan on using RAID5 in IA64
+
 config MD_RAID5_RESHAPE
 	bool "Support adding drives to a raid-5 array (experimental)"
 	depends on MD_RAID456 && EXPERIMENTAL
