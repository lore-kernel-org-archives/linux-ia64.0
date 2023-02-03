From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:16 +0000
Subject: [RFC PATCH 05/32] drivers: base: Move cpu_dev_init() after node_dev_init()
Message-Id: <20230203135043.409192-6-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

NUMA systems require the node descriptions to be ready before CPUs are
registered. This is so that the node symlinks can be created in sysfs.

Currently none of these platforms use GENERIC_CPU_DEVICES, meaning
that CPUs aren't registered by cpu_dev_init().

Move cpu_dev_init() after node_dev_init() so that NUMA architectures
can use GENERIC_CPU_DEVICES.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/base/init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/init.c b/drivers/base/init.c
index 397eb9880cec..c4954835128c 100644
--- a/drivers/base/init.c
+++ b/drivers/base/init.c
@@ -35,8 +35,8 @@ void __init driver_init(void)
 	of_core_init();
 	platform_bus_init();
 	auxiliary_bus_init();
-	cpu_dev_init();
 	memory_dev_init();
 	node_dev_init();
+	cpu_dev_init();
 	container_dev_init();
 }
-- 
2.30.2
