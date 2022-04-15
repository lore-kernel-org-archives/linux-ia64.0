From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 15 Apr 2022 19:08:14 +0000
Subject: [PATCH 4/7] sh: remove unused SLOW_DOWN_IO
Message-Id: <20220415190817.842864-5-helgaas@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220415190817.842864-1-helgaas@kernel.org>
In-Reply-To: <20220415190817.842864-1-helgaas@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chas Williams <3chas3@gmail.com>, "David S . Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>

From: Bjorn Helgaas <bhelgaas@google.com>

io.h defines SLOW_DOWN_IO only when CONF_SLOWDOWN_IO is defined, but
CONF_SLOWDOWN_IO is never defined and is in fact explicitly undefined.
Remove SLOW_DOWN_IO and related code.

N.B. 37b7a97884ba ("sh: machvec IO death.") went to some trouble to add
CONF_SLOWDOWN_IO and SLOW_DOWN_IO, for no obvious reason.  Maybe there was
some out-of-tree case that used this.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/sh/include/asm/io.h | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/arch/sh/include/asm/io.h b/arch/sh/include/asm/io.h
index cf9a3ec32406..3fe0e56eff4e 100644
--- a/arch/sh/include/asm/io.h
+++ b/arch/sh/include/asm/io.h
@@ -121,11 +121,6 @@ __BUILD_MEMORY_STRING(__raw_, q, u64)
 
 #ifdef CONFIG_HAS_IOPORT_MAP
 
-/*
- * Slowdown I/O port space accesses for antique hardware.
- */
-#undef CONF_SLOWDOWN_IO
-
 /*
  * On SuperH I/O ports are memory mapped, so we access them using normal
  * load/store instructions. sh_io_port_base is the virtual address to
@@ -145,13 +140,7 @@ static inline void __set_io_port_base(unsigned long pbase)
 extern void __iomem *__ioport_map(unsigned long addr, unsigned int size);
 #endif
 
-#ifdef CONF_SLOWDOWN_IO
-#define SLOW_DOWN_IO __raw_readw(sh_io_port_base)
-#else
-#define SLOW_DOWN_IO
-#endif
-
-#define __BUILD_IOPORT_SINGLE(pfx, bwlq, type, p, slow)			\
+#define __BUILD_IOPORT_SINGLE(pfx, bwlq, type, p)			\
 									\
 static inline void pfx##out##bwlq##p(type val, unsigned long port)	\
 {									\
@@ -159,7 +148,6 @@ static inline void pfx##out##bwlq##p(type val, unsigned long port)	\
 									\
 	__addr = __ioport_map(port, sizeof(type));			\
 	*__addr = val;							\
-	slow;								\
 }									\
 									\
 static inline type pfx##in##bwlq##p(unsigned long port)			\
@@ -169,14 +157,13 @@ static inline type pfx##in##bwlq##p(unsigned long port)			\
 									\
 	__addr = __ioport_map(port, sizeof(type));			\
 	__val = *__addr;						\
-	slow;								\
 									\
 	return __val;							\
 }
 
 #define __BUILD_IOPORT_PFX(bus, bwlq, type)				\
 	__BUILD_IOPORT_SINGLE(bus, bwlq, type, ,)			\
-	__BUILD_IOPORT_SINGLE(bus, bwlq, type, _p, SLOW_DOWN_IO)
+	__BUILD_IOPORT_SINGLE(bus, bwlq, type, _p,)
 
 #define BUILDIO_IOPORT(bwlq, type)					\
 	__BUILD_IOPORT_PFX(, bwlq, type)
-- 
2.25.1
