From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 06 Oct 2006 17:46:37 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200610061746.k96Hkbar010807@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

I think we also need to have a

	EXPORT_PER_CPU_SYMBOL_GPL(__irq_regs);

in libs/irq_regs.c.  I'm seeing errors like:

 WARNING: "per_cpu____irq_regs" [drivers/usb/host/ohci-hcd.ko] undefined!

while building modules.

-Tony

 arch/ia64/kernel/irq.c                    |    5 ++++-
 arch/ia64/kernel/irq_ia64.c               |    7 +++++--
 arch/ia64/sn/kernel/sn2/timer_interrupt.c |    2 +-
 drivers/serial/sn_console.c               |    2 +-
 4 files changed, 11 insertions(+), 5 deletions(-)

Tony Luck:
      [IA64] Fix breakage from irq change
