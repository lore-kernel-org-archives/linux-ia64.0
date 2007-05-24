From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 May 2007 23:41:47 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A018B1208@scsmsx411.amr.corp.intel.com>
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

 arch/ia64/kernel/acpi-processor.c |    2 +-
 arch/ia64/kernel/acpi.c           |    3 ++-
 arch/ia64/kernel/smpboot.c        |    4 ++--
 include/asm-ia64/acpi.h           |    7 ++-----
 4 files changed, 7 insertions(+), 9 deletions(-)

Tony Luck (2):
      [IA64] start_secondary() and smp_callin() should be __cpuinit
      [IA64] acpi_get_sysname() should be __init

Venki Pallipadi (2):
      [IA64] Fix using uninitialized data in _PDC setup
      [IA64] Cleanup acpi header to reuse the generic _PDC defines
