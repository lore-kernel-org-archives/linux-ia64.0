From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 15 Apr 2022 19:08:10 +0000
Subject: [PATCH 0/7] Remove unused SLOW_DOWN_IO
Message-Id: <20220415190817.842864-1-helgaas@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chas Williams <3chas3@gmail.com>, "David S . Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>

From: Bjorn Helgaas <bhelgaas@google.com>

Only alpha, ia64, powerpc, and sh define SLOW_DOWN_IO, and there are no
actual uses of it.  The few references to it are in situations that are
themselves unused.  Remove them all.

It should be safe to apply these independently and in any order.  The only
place SLOW_DOWN_IO is used at all is the lmc_var.h definition of DELAY,
which is itself never used.

Bjorn Helgaas (7):
  net: wan: atp: remove unused eeprom_delay()
  net: wan: lmc: remove unused DELAY()
  net: remove comments that mention obsolete __SLOW_DOWN_IO
  sh: remove unused SLOW_DOWN_IO
  powerpc: Remove unused SLOW_DOWN_IO definition
  ia64: remove unused __SLOW_DOWN_IO and SLOW_DOWN_IO definitions
  alpha: remove unused __SLOW_DOWN_IO and SLOW_DOWN_IO definitions

 arch/alpha/include/asm/io.h                  |  4 ----
 arch/ia64/include/asm/io.h                   |  4 ----
 arch/powerpc/include/asm/io.h                |  2 --
 arch/sh/include/asm/io.h                     | 17 ++---------------
 drivers/atm/nicstarmac.c                     |  5 -----
 drivers/net/ethernet/dec/tulip/winbond-840.c |  2 --
 drivers/net/ethernet/natsemi/natsemi.c       |  2 --
 drivers/net/ethernet/realtek/atp.h           |  4 ----
 drivers/net/wan/lmc/lmc_main.c               |  8 --------
 drivers/net/wan/lmc/lmc_var.h                |  8 --------
 10 files changed, 2 insertions(+), 54 deletions(-)

-- 
2.25.1
