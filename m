From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Mon, 02 Sep 2013 03:57:33 +0000
Subject: [PATCH v2 0/6] Remove the duplicated _MAT evaluation and simplify _acpi_map_lsapic()
Message-Id: <1378094259-5922-1-git-send-email-hanjun.guo@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-kernel@lists.linaro.org, linaro-acpi@lists.linaro.org, Hanjun Guo <hanjun.guo@linaro.org>

v1->v2: Return specific error value instead of just return -1, and
correct some grammar mistake in changelog.

For cpu hot add, evaluate _MAT or parse MADT will did twice to get
APIC id:
acpi_processor_add()
	acpi_processor_get_info()
		acpi_get_cpuid() will evaluate _MAT or parse MADT;
        acpi_processor_hotadd_init()
                acpi_map_lsapic() will evaluate _MAT again;

This patch set introduces apic_id in struct processor to save parsed
APIC id, and use it to remove the duplicated _MAT evaluation.

Further more, the new logical cpu number will be generated in
acpi_register_lapic(), this can be returned to remove the cpumask
allocation and operation to simplify _acpi_map_lsapic().

There are also some cleanups for the ACPI processor dirver code.


Hanjun Guo (2):
  ACPI / processor: remove unnecessary if (!pr) check
  ACPI / processor: Remove outdated comments

Jiang Liu (4):
  ACPI / processor: Introduce apic_id in struct processor to save
    parsed APIC id
  ACPI / processor: use apic_id and remove duplicated _MAT evaluation
  x86 / ACPI: simplify _acpi_map_lsapic()
  ACPI / processor: remove some dead code in acpi_processor_get_info()

 arch/ia64/kernel/acpi.c       |   38 ++----------------
 arch/x86/include/asm/mpspec.h |    2 +-
 arch/x86/kernel/acpi/boot.c   |   88 +++++++++--------------------------------
 arch/x86/kernel/apic/apic.c   |    8 ++--
 drivers/acpi/acpi_processor.c |   22 +++--------
 drivers/acpi/processor_core.c |   26 +++++++++---
 include/acpi/processor.h      |    3 ++
 include/linux/acpi.h          |    2 +-
 8 files changed, 60 insertions(+), 129 deletions(-)

-- 
1.7.9.5

