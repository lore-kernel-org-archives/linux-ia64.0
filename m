From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 15 Apr 2022 19:08:16 +0000
Subject: [PATCH 6/7] ia64: remove unused __SLOW_DOWN_IO and SLOW_DOWN_IO definitions
Message-Id: <20220415190817.842864-7-helgaas@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220415190817.842864-1-helgaas@kernel.org>
In-Reply-To: <20220415190817.842864-1-helgaas@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chas Williams <3chas3@gmail.com>, "David S . Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>

From: Bjorn Helgaas <bhelgaas@google.com>

Remove unused __SLOW_DOWN_IO and SLOW_DOWN_IO definitions.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/ia64/include/asm/io.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 6d93b923b379..1069e1730b2e 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -23,10 +23,6 @@
 #include <asm/unaligned.h>
 #include <asm/early_ioremap.h>
 
-/* We don't use IO slowdowns on the ia64, but.. */
-#define __SLOW_DOWN_IO	do { } while (0)
-#define SLOW_DOWN_IO	do { } while (0)
-
 #define __IA64_UNCACHED_OFFSET	RGN_BASE(RGN_UNCACHED)
 
 /*
-- 
2.25.1
