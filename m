From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 15 Oct 2007 16:35:42 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A02AD55EC@scsmsx411.amr.corp.intel.com>
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

 arch/ia64/Kconfig                |   10 
 arch/ia64/configs/sn2_defconfig  |  443 ++++++++++++++++-----------------------
 arch/ia64/hp/common/Makefile     |    1 
 arch/ia64/hp/common/aml_nfw.c    |  236 ++++++++++++++++++++
 arch/ia64/kernel/crash.c         |   15 -
 arch/ia64/kernel/machine_kexec.c |    6 
 arch/ia64/kernel/mca.c           |   88 +++----
 arch/ia64/kernel/mca_drv.h       |    2 
 arch/ia64/kernel/palinfo.c       |    6 
 arch/ia64/kernel/perfmon.c       |    7 
 arch/ia64/kernel/salinfo.c       |    4 
 arch/ia64/kernel/topology.c      |   12 -
 include/asm-ia64/mca.h           |    2 
 include/asm-ia64/sal.h           |   15 -
 14 files changed, 512 insertions(+), 335 deletions(-)

Bjorn Helgaas (2):
      [IA64] abstract SAL_CALL wrapper to allow other firmware entry points
      [IA64] add driver for ACPI methods to call native firmware

Jes Sorensen (1):
      [IA64] update sn2_defconfig

Kenji Kaneshige (2):
      [IA64] Fix kernel panic in kdump on INIT
      [IA64] Fix kernel hangup in kdump on INIT

Russ Anderson (2):
      [IA64] Remove needless delay in MCA rendezvous
      [IA64] Fix race when multiple cpus go through MCA

Satyam Sharma (2):
      [IA64] tree-wide: Misc __cpu{initdata, init, exit} annotations
      [IA64] perfmon: Remove exit_pfm_fs()

Simon Horman (1):
      [IA64] Remove vector from ia64_machine_kexec()
