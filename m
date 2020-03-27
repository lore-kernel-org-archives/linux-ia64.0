From: afzal mohammed <afzal.mohd.ma@gmail.com>
Date: Fri, 27 Mar 2020 16:20:18 +0000
Subject: [PATCH 0/6] Kill setup_irq()
Message-Id: <cover.1585320721.git.afzal.mohd.ma@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200321174303.GA7930@afzalpc>
In-Reply-To: <20200321174303.GA7930@afzalpc>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

Hi Thomas,

As compared to the situation mentioned earlier[1], now powerpc patch is
also in -next, and the pending ARM patches has been picked up by ARM SoC
maintainers today and is expected to show up in next -next. All other
subsytem patches has been picked by relevant maintainers & are already
in -next except alpha, c6x, hexagon, unicore32 & sh.

As it is the case, i am sending you patches for the above 5
architecture's plus the core removal patch.

Status of 5 arch's:
-------------------
alpha:		received ack from Matt Turner, build test success
c6x:		did receive ack from Mark Salter in v1, the final
		 version (v3) was with minor changes, hence removed his
		 ack & cc'ed him, build test success
hexagon:	build test success
unicore32:	couldn't get toolchain from kernel.org, 0day test robot
		 or Segher's buildall
sh:		To compile the relevant changes sh64 compiler is
		 required, couldn't get it from above mentioned 3
		 sources.

Note 1: sh toolchain is available, but that will not make the
 relevant changes compile as it has dependency of 64bit arch toolchain,
 did try a Kconfig hack to make it compile w/ 32bit sh toolchain, but it
 failed due to other reasons (unknown operands), so gave up on that.
Note 2: hexagon final image creation fails even w/o my patch, but it
 has been ensured that w/ my changes relevant object files are getting
 built  w/o warnings.

Regards
afzal

[1] https://lkml.kernel.org/r/20200321172626.GA6323@afzalpc

afzal mohammed (6):
  alpha: Replace setup_irq() by request_irq()
  c6x: replace setup_irq() by request_irq()
  hexagon: replace setup_irq() by request_irq()
  sh: replace setup_irq() by request_irq()
  unicore32: replace setup_irq() by request_irq()
  genirq: Remove setup_irq() and remove_irq()

 arch/alpha/kernel/irq_alpha.c     | 29 ++++----------------
 arch/alpha/kernel/irq_i8259.c     |  8 ++----
 arch/alpha/kernel/irq_impl.h      |  7 +----
 arch/alpha/kernel/irq_pyxis.c     |  3 ++-
 arch/alpha/kernel/sys_alcor.c     |  3 ++-
 arch/alpha/kernel/sys_cabriolet.c |  3 ++-
 arch/alpha/kernel/sys_eb64p.c     |  3 ++-
 arch/alpha/kernel/sys_marvel.c    |  2 +-
 arch/alpha/kernel/sys_miata.c     |  6 +++--
 arch/alpha/kernel/sys_ruffian.c   |  3 ++-
 arch/alpha/kernel/sys_rx164.c     |  3 ++-
 arch/alpha/kernel/sys_sx164.c     |  3 ++-
 arch/alpha/kernel/sys_wildfire.c  |  7 ++---
 arch/alpha/kernel/time.c          |  6 ++---
 arch/c6x/platforms/timer64.c      | 11 +++-----
 arch/hexagon/kernel/smp.c         | 22 ++++++++--------
 arch/hexagon/kernel/time.c        | 11 +++-----
 arch/sh/boards/mach-cayman/irq.c  | 18 +++++--------
 arch/sh/drivers/dma/dma-pvr2.c    |  9 +++----
 arch/unicore32/kernel/time.c      | 11 +++-----
 include/linux/irq.h               |  2 --
 kernel/irq/manage.c               | 44 -------------------------------
 22 files changed, 60 insertions(+), 154 deletions(-)

-- 
2.25.1
