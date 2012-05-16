From: maximilian attems <max@stro.at>
Date: Wed, 16 May 2012 07:46:30 +0000
Subject: [PATCH] ia64: add cmpxchg.h to exported userspace headers
Message-Id: <1337154390-23185-1-git-send-email-max@stro.at>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Stephan Mueller <stephan.mueller@atsec.com>, maximilian attems <max@stro.at>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>

Fixes klibc build on ia64 after 85f8f7759e418c814ee2ceacf73eddb9bed39492.

Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Tony Luck <tony.luck@intel.com>
Signed-off-by: maximilian attems <max@stro.at>
---
 arch/ia64/include/asm/Kbuild |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 241d1c5..d4eb938 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -1,6 +1,7 @@
 include include/asm-generic/Kbuild.asm
 
 header-y += break.h
+header-y += cmpxchg.h
 header-y += fpu.h
 header-y += gcc_intrin.h
 header-y += ia64regs.h
-- 
1.7.10

