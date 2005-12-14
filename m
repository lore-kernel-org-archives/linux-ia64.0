From: hawkes@sgi.com
Date: Wed, 14 Dec 2005 23:07:13 +0000
Subject: [PATCH] ia64: eliminate softlockup warning
Message-Id: <20051214230713.7528.68477.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, hawkes@sgi.com

Fix an unnecessary softlockup watchdog warning in the ia64
uncached_build_memmap() that occurs occasionally at 256p and always at
512p.  The problem occurs at boot time.

It would be good if we had a cleaner mechanism to temporarily silence
the watchdog thread, e.g.,
    http://marc.theaimsgroup.com/?l=linux-kernel&m1552476401175&w=2
but until that patch gets merged, this fix will have to suffice.

Signed-off-by: John Hawkes <hawkes@sgi.com>

Index: linux/arch/ia64/kernel/uncached.c
=================================--- linux.orig/arch/ia64/kernel/uncached.c	2005-12-06 15:12:14.000000000 -0800
+++ linux/arch/ia64/kernel/uncached.c	2005-12-14 14:50:55.000000000 -0800
@@ -210,6 +210,7 @@
 
 	dprintk(KERN_ERR "uncached_build_memmap(%lx %lx)\n", start, end);
 
+	touch_softlockup_watchdog();
 	memset((char *)start, 0, length);
 
 	node = paddr_to_nid(start - __IA64_UNCACHED_OFFSET);
