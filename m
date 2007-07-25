From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 25 Jul 2007 21:40:09 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A02024E69@scsmsx411.amr.corp.intel.com>
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

-Tony

 arch/ia64/ia32/ia32_support.c  |    8 ++--
 arch/ia64/ia32/ia32priv.h      |   12 +++---
 arch/ia64/ia32/sys_ia32.c      |   81 ++++++++++++++++++++---------------------
 arch/ia64/kernel/head.S        |    4 +-
 arch/ia64/kernel/irq_ia64.c    |   26 ++++++-------
 arch/ia64/kernel/machvec.c     |   27 +++++++++----
 arch/ia64/kernel/process.c     |    7 ++-
 arch/ia64/kernel/setup.c       |   11 ++++-
 arch/ia64/kernel/smp.c         |    2 -
 arch/ia64/kernel/smpboot.c     |    6 +--
 arch/ia64/kernel/vmlinux.lds.S |    2 +
 arch/ia64/pci/pci.c            |    2 -
 include/asm-ia64/ia32.h        |    9 ++--
 include/asm-ia64/machvec.h     |    1 
 include/asm-ia64/processor.h   |    4 +-
 include/asm-ia64/smp.h         |    1 
 16 files changed, 111 insertions(+), 92 deletions(-)

Horms (1):
      [IA64] Ensure that machvec is set up takes place before serial console

Kenji Kaneshige (1):
      [IA64] vector-domain - fix vector_table

Tony Luck (2):
      [IA64] fix section mismatch warnings
      [IA64] Nail two more simple section mismatch errors

Yasuaki Ishimatsu (1):
      [IA64] vector-domain - handle assign_irq_vector(AUTO_ASSIGN)

akpm@linux-foundation.org (1):
      [IA64] rename partial_page
