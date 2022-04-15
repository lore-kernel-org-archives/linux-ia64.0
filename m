From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 15 Apr 2022 19:08:12 +0000
Subject: [PATCH 2/7] net: wan: lmc: remove unused DELAY()
Message-Id: <20220415190817.842864-3-helgaas@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220415190817.842864-1-helgaas@kernel.org>
In-Reply-To: <20220415190817.842864-1-helgaas@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chas Williams <3chas3@gmail.com>, "David S . Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>

From: Bjorn Helgaas <bhelgaas@google.com>

lmc_var.h is included only by files in drivers/net/wan/lmc/, and none of
them uses DELAY().  Remove the unused definition and related comments.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/net/wan/lmc/lmc_main.c | 8 --------
 drivers/net/wan/lmc/lmc_var.h  | 8 --------
 2 files changed, 16 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 76c6b4f89890..45b2d25782ed 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1669,21 +1669,17 @@ unsigned lmc_mii_readreg (lmc_softc_t * const sc, unsigned devaddr, unsigned reg
 
         LMC_CSR_WRITE (sc, csr_9, dataval);
         lmc_delay ();
-        /* __SLOW_DOWN_IO; */
         LMC_CSR_WRITE (sc, csr_9, dataval | 0x10000);
         lmc_delay ();
-        /* __SLOW_DOWN_IO; */
     }
 
     for (i = 19; i > 0; i--)
     {
         LMC_CSR_WRITE (sc, csr_9, 0x40000);
         lmc_delay ();
-        /* __SLOW_DOWN_IO; */
         retval = (retval << 1) | ((LMC_CSR_READ (sc, csr_9) & 0x80000) ? 1 : 0);
         LMC_CSR_WRITE (sc, csr_9, 0x40000 | 0x10000);
         lmc_delay ();
-        /* __SLOW_DOWN_IO; */
     }
 
     return (retval >> 1) & 0xffff;
@@ -1708,10 +1704,8 @@ void lmc_mii_writereg (lmc_softc_t * const sc, unsigned devaddr, unsigned regno,
 
         LMC_CSR_WRITE (sc, csr_9, datav);
         lmc_delay ();
-        /* __SLOW_DOWN_IO; */
         LMC_CSR_WRITE (sc, csr_9, (datav | 0x10000));
         lmc_delay ();
-        /* __SLOW_DOWN_IO; */
         i--;
     }
 
@@ -1720,10 +1714,8 @@ void lmc_mii_writereg (lmc_softc_t * const sc, unsigned devaddr, unsigned regno,
     {
         LMC_CSR_WRITE (sc, csr_9, 0x40000);
         lmc_delay ();
-        /* __SLOW_DOWN_IO; */
         LMC_CSR_WRITE (sc, csr_9, 0x50000);
         lmc_delay ();
-        /* __SLOW_DOWN_IO; */
         i--;
     }
 }
diff --git a/drivers/net/wan/lmc/lmc_var.h b/drivers/net/wan/lmc/lmc_var.h
index 99f0aa787a35..cf824bb1932c 100644
--- a/drivers/net/wan/lmc/lmc_var.h
+++ b/drivers/net/wan/lmc/lmc_var.h
@@ -44,14 +44,6 @@ typedef struct lmc___ctl lmc_ctl_t;
 #define LMC_CSR_WRITE(sc, reg, val) \
 	outl((val), (sc)->lmc_csrs.reg)
 
-//#ifdef _LINUX_DELAY_H
-//	#define SLOW_DOWN_IO udelay(2);
-//	#undef __SLOW_DOWN_IO
-//	#define __SLOW_DOWN_IO udelay(2);
-//#endif
-
-#define DELAY(n) SLOW_DOWN_IO
-
 #define lmc_delay() inl(sc->lmc_csrs.csr_9)
 
 /* This macro sync's up with the mii so that reads and writes can take place */
-- 
2.25.1
