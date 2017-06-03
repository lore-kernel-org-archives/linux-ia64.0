From: Christoph Hellwig <hch@lst.de>
Date: Sat, 03 Jun 2017 19:01:01 +0000
Subject: [PATCH 4/5] signal: move copy_siginfo_to_user to <linux/signal.h>
Message-Id: <20170603190102.28866-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de>
In-Reply-To: <20170603190102.28866-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Having it in asm-generic/siginfo.h doesn't make any sense as it is in no way
architecture specific.  Move it to signal.h instead where several related
functions already reside.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/asm-generic/siginfo.h | 4 ----
 include/linux/signal.h        | 2 ++
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo.h
index 5a9394763a66..31268a5bf63e 100644
--- a/include/asm-generic/siginfo.h
+++ b/include/asm-generic/siginfo.h
@@ -14,8 +14,4 @@
 #define __SI_SYS	(7 << 16)
 #define __SI_CODE(T,N)	((T) | ((N) & 0xffff))
 
-struct siginfo;
-
-extern int copy_siginfo_to_user(struct siginfo __user *to, const struct siginfo *from);
-
 #endif
diff --git a/include/linux/signal.h b/include/linux/signal.h
index 80c7418be359..a39feddd71ba 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -19,6 +19,8 @@ static inline void copy_siginfo(struct siginfo *to, struct siginfo *from)
 		memcpy(to, from, __ARCH_SI_PREAMBLE_SIZE + sizeof(from->_sifields._sigchld));
 }
 
+int copy_siginfo_to_user(struct siginfo __user *to, const struct siginfo *from);
+
 /*
  * Define some primitives to manipulate sigset_t.
  */
-- 
2.11.0

