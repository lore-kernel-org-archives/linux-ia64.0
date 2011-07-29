From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 29 Jul 2011 17:43:19 +0000
Subject: [git pull] pstore + ia64 changes
Message-Id: <4e32f13721205e7dbe@agluck-desktop.sc.intel.com>
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

 Documentation/ABI/testing/pstore    |    6 +
 Documentation/kernel-parameters.txt |    2 +
 arch/ia64/Kconfig                   |    4 +
 arch/ia64/include/asm/gpio.h        |   55 ++++++++
 drivers/acpi/apei/erst.c            |   20 ++-
 drivers/firmware/efivars.c          |  243 +++++++++++++++++++++++++++++++++--
 fs/pstore/inode.c                   |   12 +-
 fs/pstore/internal.h                |    2 +-
 fs/pstore/platform.c                |   30 +++-
 include/linux/efi.h                 |    6 +
 include/linux/pstore.h              |    9 +-
 11 files changed, 355 insertions(+), 34 deletions(-)
 create mode 100644 arch/ia64/include/asm/gpio.h

Mark Brown (1):
      [IA64] Hook up gpiolib support

Matthew Garrett (5):
      pstore: Extend API for more flexibility in new backends
      pstore: Add extra context for writes and erases
      pstore: Make "part" unsigned
      pstore: Allow the user to explicitly choose a backend
      efi: Add support for using efivars as a pstore backend

Mike Waychison (4):
      efivars: String functions
      efivars: introduce utf16_strncmp
      efivars: Use string functions in pstore_write
      efivars: Introduce PSTORE_EFI_ATTRIBUTES

