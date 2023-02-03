From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:24 +0000
Subject: [RFC PATCH 13/32] ACPI: processor: Register all CPUs from acpi_processor_get_info()
Message-Id: <20230203135043.409192-14-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

To allow ACPI to skip the call to arch_register_cpu() when the _STA
value indicates the CPU can't be brought online right now, move the
arch_register_cpu() call into acpi_processor_get_info().

Systems can still be booted with 'acpi=off', or in the case of arm64,
not include an ACPI description at all. For these, the CPUs are
registered by cpu_dev_register_generic().

This moves the CPU register logic back to a subsys_initcall(),
while the memory nodes will have been registered earlier.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/acpi_processor.c | 6 ++++++
 drivers/base/cpu.c            | 2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index 967837b60453..a93a6c4115c4 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -272,6 +272,12 @@ static int acpi_processor_get_info(struct acpi_device *device)
 			pr->id = 0;
 	}
 
+	if (!invalid_logical_cpuid(pr->id) && cpu_present(pr->id)) {
+		int ret = arch_register_cpu(pr->id);
+		if (ret)
+			return ret;
+	}
+
 	/*
 	 *  Extra Processor objects may be enumerated on MP systems with
 	 *  less than the max # of CPUs. They should be ignored _iff
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index 178936533d87..0ba646022a5e 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -504,7 +504,7 @@ static void __init cpu_dev_register_generic(void)
 {
 	int i;
 
-	if (!IS_ENABLED(CONFIG_GENERIC_CPU_DEVICES))
+	if (!IS_ENABLED(CONFIG_GENERIC_CPU_DEVICES) || !acpi_disabled)
 		return;
 
 	for_each_present_cpu(i) {
-- 
2.30.2
