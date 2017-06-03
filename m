From: Christoph Hellwig <hch@lst.de>
Date: Sat, 03 Jun 2017 19:00:58 +0000
Subject: [PATCH 1/5] sparc: simplify <asm/siginfo.h>
Message-Id: <20170603190102.28866-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de>
In-Reply-To: <20170603190102.28866-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

There is no need for the forward declaration of compat_siginfo provided
here.  We can't yet use the generic header as we need to pull in the
sparc-specific version of the uapi <asm/siginfo.h>, but this prepares
for removing the non-uapi <asm/siginfo.h> entirely.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/include/asm/siginfo.h | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/arch/sparc/include/asm/siginfo.h b/arch/sparc/include/asm/siginfo.h
index 48c34c19f810..dd2f2fce976b 100644
--- a/arch/sparc/include/asm/siginfo.h
+++ b/arch/sparc/include/asm/siginfo.h
@@ -1,13 +1 @@
-#ifndef __SPARC_SIGINFO_H
-#define __SPARC_SIGINFO_H
-
 #include <uapi/asm/siginfo.h>
-
-
-#ifdef CONFIG_COMPAT
-
-struct compat_siginfo;
-
-#endif /* CONFIG_COMPAT */
-
-#endif /* !(__SPARC_SIGINFO_H) */
-- 
2.11.0

