From: Bill Nottingham <notting@redhat.com>
Date: Thu, 07 Dec 2000 00:55:30 +0000
Subject: [Linux-ia64] Re: TurboLinux IA-64 Beta 2 (2000-11-23) Available for download
MIME-Version: 1
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Message-Id: <marc-linux-ia64-105590678205802@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Don Dugger (n0ano@tlaloc.n0ano.com) said: 
> I tried to re-compile X on this release and came across a problem.
> The include file `/usr/include/asm/io.h' defines the in/out functions
> in terms of new `platform_*' functions, which are not defined for
> user programs.  Do you know where these `platform_*' functions are
> supposed to be defined?

Try this. Must not include kernel headers in userland, blah, blah, blah.

Bill

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="XFree86-4.0.1-ia64-dainbramage.patch"

--- XFree86-4.0.1/xc/programs/Xserver/hw/xfree86/SuperProbe/Probe.h.dainbramage	Mon Nov 20 01:17:10 2000
+++ XFree86-4.0.1/xc/programs/Xserver/hw/xfree86/SuperProbe/Probe.h	Mon Nov 20 01:17:20 2000
@@ -47,7 +47,6 @@
 #if defined(SYSV) || defined(SVR4) || defined(linux) || defined(__QNX__) || defined(__QNXNTO__)
 #if defined(__ia64__)
 #include <sys/io.h>
-#include <asm/io.h>
 #endif
 # include <string.h>
 #if !(defined(__QNX__) && !defined(__QNXNTO__))
--- XFree86-4.0.1/xc/programs/Xserver/hw/xfree86/SuperProbe/AsmMacros.h.dainbramage	Mon Nov 20 01:19:10 2000
+++ XFree86-4.0.1/xc/programs/Xserver/hw/xfree86/SuperProbe/AsmMacros.h	Mon Nov 20 01:18:31 2000
@@ -69,9 +69,8 @@
 #define outl(p,v) _outl((v),(p))
 #elif defined(linux) && defined(__ia64__)
 #include <stdlib.h>
-#include <asm/types.h>
-#include <asm/system.h>
-#include <asm/io.h>
+#include <sys/types.h>
+#include <sys/io.h>
 #else
 #if defined(__sparc__)
 #ifndef ASI_PL

--YiEDa0DAkWCtVeE4--

