From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 15 Apr 2022 19:08:13 +0000
Subject: [PATCH 3/7] net: remove comments that mention obsolete __SLOW_DOWN_IO
Message-Id: <20220415190817.842864-4-helgaas@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220415190817.842864-1-helgaas@kernel.org>
In-Reply-To: <20220415190817.842864-1-helgaas@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chas Williams <3chas3@gmail.com>, "David S . Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>

From: Bjorn Helgaas <bhelgaas@google.com>

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/atm/nicstarmac.c                     | 5 -----
 drivers/net/ethernet/dec/tulip/winbond-840.c | 2 --
 drivers/net/ethernet/natsemi/natsemi.c       | 2 --
 3 files changed, 9 deletions(-)

diff --git a/drivers/atm/nicstarmac.c b/drivers/atm/nicstarmac.c
index e0dda9062e6b..791f69a07ddf 100644
--- a/drivers/atm/nicstarmac.c
+++ b/drivers/atm/nicstarmac.c
@@ -14,11 +14,6 @@ typedef void __iomem *virt_addr_t;
 
 #define CYCLE_DELAY 5
 
-/*
-   This was the original definition
-#define osp_MicroDelay(microsec) \
-    do { int _i = 4*microsec; while (--_i > 0) { __SLOW_DOWN_IO; }} while (0)
-*/
 #define osp_MicroDelay(microsec) {unsigned long useconds = (microsec); \
                                   udelay((useconds));}
 /*
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 86b1d23eba83..1db19463fd46 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -474,8 +474,6 @@ static int w840_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
    No extra delay is needed with 33Mhz PCI, but future 66Mhz access may need
    a delay.  Note that pre-2.0.34 kernels had a cache-alignment bug that
    made udelay() unreliable.
-   The old method of using an ISA access as a delay, __SLOW_DOWN_IO__, is
-   deprecated.
 */
 #define eeprom_delay(ee_addr)	ioread32(ee_addr)
 
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 82a22711ce45..50bca486a244 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -989,8 +989,6 @@ static int natsemi_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
    No extra delay is needed with 33Mhz PCI, but future 66Mhz access may need
    a delay.  Note that pre-2.0.34 kernels had a cache-alignment bug that
    made udelay() unreliable.
-   The old method of using an ISA access as a delay, __SLOW_DOWN_IO__, is
-   deprecated.
 */
 #define eeprom_delay(ee_addr)	readl(ee_addr)
 
-- 
2.25.1
