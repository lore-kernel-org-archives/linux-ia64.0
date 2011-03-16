From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Mar 2011 20:59:35 +0000
Subject: [git pull] ia64 and /dev/pstore changes
Message-Id: <4d8124b7211921a163@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Reminder: the "pstore" part is a filesystem that is the interface
to some platform specific persistent store (e.g. ACPI "ERST") that
can save the last part of the console log on an oops or crash and
make it visible as a file. Deleting the file clears the entry in
the underlying persistent store.

The version here includes all your feedback (so it logs "oops" as
well as "panic"). Several people said they liked this and would try
it out, but only one bug report resulted (thanks sfr).

It's a separate topic branch, merged into my tree after the ia64
bits - so if you don't want it in this merge it should be easy to
pop it off but still take the ia64 parts.

Thanks!

-Tony

 Documentation/ABI/testing/pstore          |   35 ++++
 Documentation/ABI/testing/sysfs-fs-pstore |    7 +
 arch/ia64/configs/generic_defconfig       |    1 +
 arch/ia64/configs/gensparse_defconfig     |    1 +
 arch/ia64/include/asm/dma-mapping.h       |    2 +
 arch/ia64/kernel/mca.c                    |    5 +-
 arch/ia64/sn/kernel/setup.c               |    2 +-
 arch/ia64/sn/pci/tioca_provider.c         |    2 +-
 drivers/acpi/apei/Kconfig                 |    1 +
 drivers/acpi/apei/erst.c                  |  136 ++++++++++++++
 fs/Kconfig                                |    1 +
 fs/Makefile                               |    1 +
 fs/pstore/Kconfig                         |   13 ++
 fs/pstore/Makefile                        |    7 +
 fs/pstore/inode.c                         |  285 +++++++++++++++++++++++++++++
 fs/pstore/internal.h                      |    7 +
 fs/pstore/platform.c                      |  202 ++++++++++++++++++++
 include/linux/magic.h                     |    1 +
 include/linux/pstore.h                    |   60 ++++++
 19 files changed, 766 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/ABI/testing/pstore
 create mode 100644 Documentation/ABI/testing/sysfs-fs-pstore
 create mode 100644 fs/pstore/Kconfig
 create mode 100644 fs/pstore/Makefile
 create mode 100644 fs/pstore/inode.c
 create mode 100644 fs/pstore/internal.h
 create mode 100644 fs/pstore/platform.c
 create mode 100644 include/linux/pstore.h

Jeff Mahoney (2):
      [IA64] mca.c: Fix cast from integer to pointer warning
      [IA64] tioca: Fix assignment from incompatible pointer warnings

Justin P. Mattock (1):
      [IA64] setup.c Typo fix "Architechtuallly"

Konrad Rzeszutek Wilk (1):
      [IA64] Add DMA_ERROR_CODE define.

Tony Luck (5):
      pstore: new filesystem interface to platform persistent storage
      pstore: X86 platform interface using ACPI/APEI/ERST
      pstore: fix build warning for unused return value from sysfs_create_file
      [IA64] disable interrupts at end of ia64_mca_cpe_int_handler()
      [IA64] Add CONFIG_MISC_DEVICES=y to configs that need it.

