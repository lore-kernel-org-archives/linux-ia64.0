From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 May 2007 20:13:08 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A0184DC3A@scsmsx411.amr.corp.intel.com>
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

 arch/ia64/kernel/process.c  |    5 +++++
 arch/ia64/kernel/unwind.c   |   21 ++++++++++++++-------
 arch/ia64/pci/pci.c         |   11 +++++++----
 arch/ia64/sn/kernel/setup.c |    2 +-
 include/asm-ia64/unistd.h   |   13 +++++++++++++
 5 files changed, 40 insertions(+), 12 deletions(-)

Kenji Kaneshige (1):
      [IA64] fix kmalloc(0) in arch/ia64/pci/pci.c

Robin Holt (2):
      [IA64] Improve unwind checking.
      [IA64] Only unwind non-running tasks.

Tony Luck (2):
      [IA64] Fix bogus messages about system calls not implemented.
      [IA64] Yet another section mismatch warning
