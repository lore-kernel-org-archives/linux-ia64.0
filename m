From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 13 Jan 2017 10:46:44 +0000
Subject: [PATCH v3 6/8] Makefile.headersinst: remove destination-y option
Message-Id: <1484304406-10820-7-git-send-email-nicolas.dichtel@6wind.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie, daniel.vetter@ffwll.ch, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, linux@armlinux.org.uk, hch@infradead.org, coreteam@netfilter.org, msalter@redhat.com, fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68k.org

This option was added in commit c7bb349e7c25 ("kbuild: introduce destination-y
for exported headers") but never used in-tree.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/kbuild/makefiles.txt | 23 ++++-------------------
 scripts/Makefile.headersinst       |  2 +-
 2 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
index 9b9c4797fc55..37b525d329ae 100644
--- a/Documentation/kbuild/makefiles.txt
+++ b/Documentation/kbuild/makefiles.txt
@@ -46,9 +46,8 @@ This document describes the Linux kernel Makefiles.
 	== 7 Kbuild syntax for exported headers
 		--- 7.1 header-y
 		--- 7.2 genhdr-y
-		--- 7.3 destination-y
-		--- 7.4 generic-y
-		--- 7.5 generated-y
+		--- 7.3 generic-y
+		--- 7.4 generated-y
 
 	== 8 Kbuild Variables
 	== 9 Makefile language
@@ -1295,21 +1294,7 @@ See subsequent chapter for the syntax of the Kbuild file.
 			#include/linux/Kbuild
 			genhdr-y += version.h
 
-	--- 7.3 destination-y
-
-	When an architecture has a set of exported headers that needs to be
-	exported to a different directory destination-y is used.
-	destination-y specifies the destination directory for all exported
-	headers in the file where it is present.
-
-		Example:
-			#arch/xtensa/platforms/s6105/include/platform/Kbuild
-			destination-y := include/linux
-
-	In the example above all exported headers in the Kbuild file
-	will be located in the directory "include/linux" when exported.
-
-	--- 7.4 generic-y
+	--- 7.3 generic-y
 
 	If an architecture uses a verbatim copy of a header from
 	include/asm-generic then this is listed in the file
@@ -1336,7 +1321,7 @@ See subsequent chapter for the syntax of the Kbuild file.
 		Example: termios.h
 			#include <asm-generic/termios.h>
 
-	--- 7.5 generated-y
+	--- 7.4 generated-y
 
 	If an architecture generates other header files alongside generic-y
 	wrappers, and not included in genhdr-y, then generated-y specifies
diff --git a/scripts/Makefile.headersinst b/scripts/Makefile.headersinst
index 3e20d03432d2..876b42cfede4 100644
--- a/scripts/Makefile.headersinst
+++ b/scripts/Makefile.headersinst
@@ -14,7 +14,7 @@ kbuild-file := $(srctree)/$(obj)/Kbuild
 include $(kbuild-file)
 
 # called may set destination dir (when installing to asm/)
-_dst := $(if $(destination-y),$(destination-y),$(if $(dst),$(dst),$(obj)))
+_dst := $(if $(dst),$(dst),$(obj))
 
 old-kbuild-file := $(srctree)/$(subst uapi/,,$(obj))/Kbuild
 ifneq ($(wildcard $(old-kbuild-file)),)
-- 
2.8.1

