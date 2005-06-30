From: Bob Picco <bob.picco@hp.com>
Date: Thu, 30 Jun 2005 01:00:27 +0000
Subject: [PATCH] Documentation
Message-Id: <20050630010027.GJ25758@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony:

This is a small documentation patch for a boot time parameter.  

thanks,

bob

Signed-off-by: Bob Picco <bob.picco@hp.com>

Index: linux-git.linus/Documentation/kernel-parameters.txt
=================================--- linux-git.linus.orig/Documentation/kernel-parameters.txt	2005-06-14 13:30:31.000000000 -0400
+++ linux-git.linus/Documentation/kernel-parameters.txt	2005-06-27 10:00:43.000000000 -0400
@@ -736,6 +736,9 @@ running once the system is up.
 	maxcpus=	[SMP] Maximum number of processors that	an SMP kernel
 			should make use of
 
+	max_addr=[KMG]	[KNL,BOOT,ia64] All physical memory greater than or
+			equal to this physical address is ignored.
+
 	max_luns=	[SCSI] Maximum number of LUNs to probe
 			Should be between 1 and 2^32-1.
 
