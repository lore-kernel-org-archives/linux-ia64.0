From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 20 May 2011 18:58:41 +0000
Subject: [git pull] pstore and ia64 changes
Message-Id: <4dd6b9e1199552af9d@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/vmlinux.lds.S |    1 +
 arch/ia64/oprofile/backtrace.c |    2 +-
 drivers/acpi/apei/Kconfig      |    1 +
 drivers/acpi/apei/erst.c       |   61 +++++++++++++++++++++++++++++----------
 fs/pstore/platform.c           |   12 ++++++--
 include/linux/pstore.h         |    4 ++-
 6 files changed, 60 insertions(+), 21 deletions(-)

Chen Gong (3):
      pstore: fix one type of return value in pstore
      pstore: fix pstore filesystem mount/remount issue
      pstore: fix potential logic issue in pstore read interface

Tony Luck (3):
      [IA64] fix build warning in arch/ia64/oprofile/backtrace.c
      pstore: Fix Kconfig dependencies for apei->pstore
      [IA64] define "_sdata" symbol

