From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 06 Jun 2006 16:23:34 +0000
Subject: [PATCH] add vmlinuz target
Message-Id: <1149611014.5920.36.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   This is a trivial stand-alone patch out of the Xen/ia64 patches.  Add
a vmlinuz build target to be more compatible with x86-ish targets.
Thanks,

	Alex

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

diff -r d349717b8dc8 arch/ia64/Makefile
--- a/arch/ia64/Makefile	Tue Jun 06 01:00:10 2006 +0000
+++ b/arch/ia64/Makefile	Tue Jun 06 10:20:10 2006 -0600
@@ -71,6 +71,8 @@ all: compressed unwcheck
 
 compressed: vmlinux.gz
 
+vmlinuz: vmlinux.gz
+
 vmlinux.gz: vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 


