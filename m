From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 20 Aug 2013 19:38:03 +0000
Subject: [PATCH] Kconfig: Remove hotplug enable hints in CONFIG_KEXEC help texts
Message-Id: <1377027483-17025-1-git-send-email-geert@linux-m68k.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

commit 40b313608ad4ea655addd2ec6cdd106477ae8e15 ("Finally eradicate
CONFIG_HOTPLUG") removed remaining references to CONFIG_HOTPLUG, but missed
a few plain English references in the CONFIG_KEXEC help texts.

Remove them, too.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/arm/Kconfig     |    3 +--
 arch/ia64/Kconfig    |    6 +++---
 arch/mips/Kconfig    |    6 +++---
 arch/powerpc/Kconfig |    6 +++---
 arch/sh/Kconfig      |    6 +++---
 arch/x86/Kconfig     |    6 +++---
 6 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 43594d5..cd5c1c9 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -2064,8 +2064,7 @@ config KEXEC
 
 	  It is an ongoing process to be certain the hardware in a machine
 	  is properly shutdown, so do not be surprised if this code does not
-	  initially work for you.  It may help to enable device hotplugging
-	  support.
+	  initially work for you.
 
 config ATAGS_PROC
 	bool "Export atags in procfs"
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 5a768ad..b36370d 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -565,9 +565,9 @@ config KEXEC
 
 	  It is an ongoing process to be certain the hardware in a machine
 	  is properly shutdown, so do not be surprised if this code does not
-	  initially work for you.  It may help to enable device hotplugging
-	  support.  As of this writing the exact hardware interface is
-	  strongly in flux, so no good recommendation can be made.
+	  initially work for you.  As of this writing the exact hardware
+	  interface is strongly in flux, so no good recommendation can be
+	  made.
 
 config CRASH_DUMP
 	  bool "kernel crash dumps"
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index e12764c..dccd7ce 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -2305,9 +2305,9 @@ config KEXEC
 
 	  It is an ongoing process to be certain the hardware in a machine
 	  is properly shutdown, so do not be surprised if this code does not
-	  initially work for you.  It may help to enable device hotplugging
-	  support.  As of this writing the exact hardware interface is
-	  strongly in flux, so no good recommendation can be made.
+	  initially work for you.  As of this writing the exact hardware
+	  interface is strongly in flux, so no good recommendation can be
+	  made.
 
 config CRASH_DUMP
 	  bool "Kernel crash dumps"
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index dbd9d3c..cc61418 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -369,9 +369,9 @@ config KEXEC
 
 	  It is an ongoing process to be certain the hardware in a machine
 	  is properly shutdown, so do not be surprised if this code does not
-	  initially work for you.  It may help to enable device hotplugging
-	  support.  As of this writing the exact hardware interface is
-	  strongly in flux, so no good recommendation can be made.
+	  initially work for you.  As of this writing the exact hardware
+	  interface is strongly in flux, so no good recommendation can be
+	  made.
 
 config CRASH_DUMP
 	bool "Build a kdump crash kernel"
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 1020dd8..1018ed3 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -643,9 +643,9 @@ config KEXEC
 
 	  It is an ongoing process to be certain the hardware in a machine
 	  is properly shutdown, so do not be surprised if this code does not
-	  initially work for you.  It may help to enable device hotplugging
-	  support.  As of this writing the exact hardware interface is
-	  strongly in flux, so no good recommendation can be made.
+	  initially work for you.  As of this writing the exact hardware
+	  interface is strongly in flux, so no good recommendation can be
+	  made.
 
 config CRASH_DUMP
 	bool "kernel crash dumps (EXPERIMENTAL)"
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b32ebf9..6ace5de 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1627,9 +1627,9 @@ config KEXEC
 
 	  It is an ongoing process to be certain the hardware in a machine
 	  is properly shutdown, so do not be surprised if this code does not
-	  initially work for you.  It may help to enable device hotplugging
-	  support.  As of this writing the exact hardware interface is
-	  strongly in flux, so no good recommendation can be made.
+	  initially work for you.  As of this writing the exact hardware
+	  interface is strongly in flux, so no good recommendation can be
+	  made.
 
 config CRASH_DUMP
 	bool "kernel crash dumps"
-- 
1.7.9.5

