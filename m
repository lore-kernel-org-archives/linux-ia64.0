From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:19:04 +0000
Subject: [PATCH 00/11] ACPI: early _PDC eval and unify x86/ia64
Message-Id: <20091220190434.4274.67855.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

It was recently discovered that some BIOS implementations load
dynamic SSDTs when a processor's _PDC method is evaluated.

In Linux, we do not evaluate _PDC until after we initialize the EC.

Unfortunately, that same BIOS references objects in the dynamic
table during EC enablement. So we get undefined references to
methods during enablement, and we fail to initialize certain pieces
of hardware.

Windows works just fine on this machine, so to me, this is a hint
that Linux should be evaluating _PDC much earlier.

The first patch in this series does just that and makes Linux
more compatible with Windows' ACPI implementation.

The remaining 10 patches unify the x86/ia64 implementations of
calling _PDC. I noticed the two archs were way more similar than
they were different, so I thought it made sense to combine them
as much as possible.

This patch series was built on both x86 and ia64 (checkpatch and
sparse clean).

It was also boot tested on an HP Envy 15 (x86) and an HP rx6600
(ia64). It resolved the namespace failures on the Envy 15 and did
not cause any regressions on the rx6600.

This does introduce a boot time namespace walk for all the CPUs
in the system, looking for and evaluating _PDC. Hopefully that
will not make life miserable for the giant SGI clusters. If worse
comes to worse, maybe we can quirk them and avoid the namespace
walk.

Thanks,
/ac

---

Alex Chiang (11):
      ACPI: processor: call _PDC early
      ACPI: processor: introduce arch_has_acpi_pdc
      ACPI: processor: unify arch_acpi_processor_init_pdc
      ACPI: processor: factor out common _PDC settings
      ACPI: processor: finish unifying arch_acpi_processor_init_pdc()
      ACPI: processor: unify arch_acpi_processor_cleanup_pdc
      ACPI: processor: introduce acpi_processor_alloc_pdc()
      ACPI: processor: change acpi_processor_eval_pdc interface
      ACPI: processor: open code acpi_processor_cleanup_pdc
      ACPI: processor: change acpi_processor_set_pdc() interface
      ACPI: processor: remove _PDC object list from struct acpi_processor


 arch/ia64/include/asm/acpi.h      |    6 +
 arch/ia64/kernel/Makefile         |    4 -
 arch/ia64/kernel/acpi-processor.c |   85 -------------------
 arch/x86/include/asm/acpi.h       |   26 ++++++
 arch/x86/kernel/acpi/Makefile     |    2 
 arch/x86/kernel/acpi/processor.c  |  101 -----------------------
 drivers/acpi/Makefile             |    1 
 drivers/acpi/bus.c                |    2 
 drivers/acpi/internal.h           |    1 
 drivers/acpi/processor_core.c     |   71 ----------------
 drivers/acpi/processor_pdc.c      |  165 +++++++++++++++++++++++++++++++++++++
 include/acpi/processor.h          |    8 +-
 12 files changed, 206 insertions(+), 266 deletions(-)
 delete mode 100644 arch/ia64/kernel/acpi-processor.c
 delete mode 100644 arch/x86/kernel/acpi/processor.c
 create mode 100644 drivers/acpi/processor_pdc.c

