From: Thomas Gleixner <tglx@linutronix.de>
Date: Sun, 04 Jun 2017 13:13:11 +0000
Subject: Re: [PATCH 5/5] remove non-uapi <asm/siginfo.h>
Message-Id: <alpine.DEB.2.20.1706041510440.2813@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de> <20170603190102.28866-6-hch@lst.de>
In-Reply-To: <20170603190102.28866-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Arnd Bergmann <arnd@arndb.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, 3 Jun 2017, Christoph Hellwig wrote:

> By moving the kernel side __SI_* defintions right next to the userspace
> ones we can kill the non-uapi versions of <asm/siginfo.h> include
> include/asm-generic/siginfo.h and untangle the unholy mess of includes.

That needs a couple of fixups and we can remove

arch/X/include/uapi/asm/siginfo.h from m32r, microblaze, mn10300 and score.

Delta patch below.

Thanks,

	tglx

8<--------------------
--- a/arch/sh/include/uapi/asm/Kbuild
+++ b/arch/sh/include/uapi/asm/Kbuild
@@ -1,3 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
 generic-y += siginfo.h
--- a/arch/arc/include/uapi/asm/Kbuild
+++ b/arch/arc/include/uapi/asm/Kbuild
@@ -1,2 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
+generic-y += siginfo.h
--- a/arch/hexagon/include/uapi/asm/Kbuild
+++ b/arch/hexagon/include/uapi/asm/Kbuild
@@ -1,2 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
+generic-y += siginfo.h
--- a/arch/m32r/include/uapi/asm/Kbuild
+++ b/arch/m32r/include/uapi/asm/Kbuild
@@ -1,2 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
+generic-y	+= siginfo.h
--- a/arch/m32r/include/uapi/asm/siginfo.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _M32R_SIGINFO_H
-#define _M32R_SIGINFO_H
-
-#include <asm-generic/siginfo.h>
-
-#endif /* _M32R_SIGINFO_H */
--- a/arch/microblaze/include/uapi/asm/Kbuild
+++ b/arch/microblaze/include/uapi/asm/Kbuild
@@ -2,3 +2,4 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += types.h
+generic-y += siginfo.h
--- a/arch/microblaze/include/uapi/asm/siginfo.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/siginfo.h>
--- a/arch/mn10300/include/uapi/asm/Kbuild
+++ b/arch/mn10300/include/uapi/asm/Kbuild
@@ -1,2 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
+generic-y	+= siginfo.h
--- a/arch/mn10300/include/uapi/asm/siginfo.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/siginfo.h>
--- a/arch/score/include/uapi/asm/Kbuild
+++ b/arch/score/include/uapi/asm/Kbuild
@@ -1,2 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
+
+generic-y	+= siginfo.h
--- a/arch/score/include/uapi/asm/siginfo.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _ASM_SCORE_SIGINFO_H
-#define _ASM_SCORE_SIGINFO_H
-
-#include <asm-generic/siginfo.h>
-
-#endif /* _ASM_SCORE_SIGINFO_H */
--- a/arch/unicore32/include/uapi/asm/Kbuild
+++ b/arch/unicore32/include/uapi/asm/Kbuild
@@ -2,3 +2,4 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += kvm_para.h
+generic-y += siginfo.h
