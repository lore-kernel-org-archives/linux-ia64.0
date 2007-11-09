From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Nov 2007 23:09:44 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A02E9A176@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Luck, Tony" <tony.luck@intel.com>
To: torvalds@linux-foundation.org
cc: linux-ia64@vger.kernel.org
Subject: git pull on ia64 linux tree
Reply-to: tony.luck@intel.com

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/sim/boot/fw-emu.c |    2 
 arch/ia64/ia32/ia32priv.h      |    1 
 arch/ia64/kernel/.gitignore    |    1 
 arch/ia64/kernel/acpi.c        |    8 ++-
 arch/ia64/kernel/efi.c         |    5 +-
 arch/ia64/kernel/iosapic.c     |   18 ++++++--
 arch/ia64/kernel/irq.c         |    6 +-
 arch/ia64/kernel/mca.c         |    2 
 arch/ia64/kernel/palinfo.c     |   91 +++++++++++++++++++++++++++++++++++------
 arch/ia64/kernel/patch.c       |    3 -
 arch/ia64/kernel/perfmon.c     |    4 -
 arch/ia64/mm/contig.c          |   74 ++++++++++++++++++---------------
 arch/ia64/sn/kernel/irq.c      |    8 +++
 arch/ia64/sn/kernel/xpc_main.c |   12 +----
 include/asm-ia64/pal.h         |    5 +-
 15 files changed, 165 insertions(+), 75 deletions(-)

Dean Nelson (1):
      [IA64] XPC heartbeat timer function must run on CPU 0

George Beshers (1):
      [IA64] IOSAPIC bogus error cleanup

Kenji Kaneshige (2):
      [IA64] Clean up /proc/interrupts output
      [IA64] Fix IOSAPIC delivery mode setting

Li Zefan (1):
      [IA64] Wrong args to memset in efi_gettimeofday()

Lucas Woods (1):
      [IA64] Remove duplicate includes from ia32priv.h

Peter Chubb (1):
      [IA64] Add gate.lds to list of files ignored by Git

Roel Kluin (1):
      [IA64] fix number of bytes zeroed by sys_fw_init() in arch/ia64/hp/sim/boot/fw-emu.c

Russ Anderson (3):
      [IA64] Clean-up McKinley Errata message
      [IA64] Disable/re-enable CPE interrupts on Altix
      [IA64] Update printing of feature set bits

Tony Luck (2):
      [IA64] Fix perfmon sysctl directory modes
      [IA64] Fix section mismatch in contig.c version of per_cpu_init()
