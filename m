From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 15 Apr 2022 19:08:11 +0000
Subject: [PATCH 1/7] net: wan: atp: remove unused eeprom_delay()
Message-Id: <20220415190817.842864-2-helgaas@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220415190817.842864-1-helgaas@kernel.org>
In-Reply-To: <20220415190817.842864-1-helgaas@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chas Williams <3chas3@gmail.com>, "David S . Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>

From: Bjorn Helgaas <bhelgaas@google.com>

atp.h is included only by atp.c, which does not use eeprom_delay().  Remove
the unused definition.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/net/ethernet/realtek/atp.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/atp.h b/drivers/net/ethernet/realtek/atp.h
index 63f0d2d0e87b..b202184eddd4 100644
--- a/drivers/net/ethernet/realtek/atp.h
+++ b/drivers/net/ethernet/realtek/atp.h
@@ -255,10 +255,6 @@ static inline void write_word_mode0(short ioaddr, unsigned short value)
 #define EE_DATA_WRITE	0x01	/* EEPROM chip data in. */
 #define EE_DATA_READ	0x08	/* EEPROM chip data out. */
 
-/* Delay between EEPROM clock transitions. */
-#define eeprom_delay(ticks) \
-do { int _i = 40; while (--_i > 0) { __SLOW_DOWN_IO; } } while (0)
-
 /* The EEPROM commands include the alway-set leading bit. */
 #define EE_WRITE_CMD(offset)	(((5 << 6) + (offset)) << 17)
 #define EE_READ(offset)		(((6 << 6) + (offset)) << 17)
-- 
2.25.1
