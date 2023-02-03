From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:31 +0000
Subject: [RFC PATCH 20/32] drivers: base: Implement weak arch_unregister_cpu()
Message-Id: <20230203135043.409192-21-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Add arch_unregister_cpu() to allow the ACPI machinery to call
unregister_cpu(). This is enough for arm64, but needs to be
overridden by x86 and ia64 who need to do more work.

CC: Jean-Philippe Brucker <jean-philippe@linaro.org>
Signed-off-by: James Morse <james.morse@arm.com>
---
 arch/ia64/include/asm/cpu.h      | 4 ----
 arch/loongarch/include/asm/cpu.h | 6 ------
 arch/x86/include/asm/cpu.h       | 1 -
 drivers/base/cpu.c               | 5 +++++
 4 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/include/asm/cpu.h b/arch/ia64/include/asm/cpu.h
index 6e9786c6ec98..3b36c6a382bb 100644
--- a/arch/ia64/include/asm/cpu.h
+++ b/arch/ia64/include/asm/cpu.h
@@ -9,8 +9,4 @@
 
 DECLARE_PER_CPU(int, cpu_state);
 
-#ifdef CONFIG_HOTPLUG_CPU
-extern void arch_unregister_cpu(int);
-#endif
-
 #endif /* _ASM_IA64_CPU_H_ */
diff --git a/arch/loongarch/include/asm/cpu.h b/arch/loongarch/include/asm/cpu.h
index 1e2c7c61dbea..754f28506791 100644
--- a/arch/loongarch/include/asm/cpu.h
+++ b/arch/loongarch/include/asm/cpu.h
@@ -124,10 +124,4 @@ enum cpu_type_enum {
 #define LOONGARCH_CPU_GUESTID		BIT_ULL(CPU_FEATURE_GUESTID)
 #define LOONGARCH_CPU_HYPERVISOR	BIT_ULL(CPU_FEATURE_HYPERVISOR)
 
-#if !defined(__ASSEMBLY__)
-#ifdef CONFIG_HOTPLUG_CPU
-extern void arch_unregister_cpu(int);
-#endif
-#endif /* ! __ASSEMBLY__ */
-
 #endif /* _ASM_CPU_H */
diff --git a/arch/x86/include/asm/cpu.h b/arch/x86/include/asm/cpu.h
index 2955541abebb..e5d820be3b72 100644
--- a/arch/x86/include/asm/cpu.h
+++ b/arch/x86/include/asm/cpu.h
@@ -24,7 +24,6 @@ static inline void prefill_possible_map(void) {}
 #endif /* CONFIG_SMP */
 
 #ifdef CONFIG_HOTPLUG_CPU
-extern void arch_unregister_cpu(int);
 extern void start_cpu0(void);
 #ifdef CONFIG_DEBUG_HOTPLUG_CPU0
 extern int _debug_hotplug_cpu(int cpu, int action);
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index 0ba646022a5e..bc2ce8c7f383 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -498,6 +498,11 @@ int __weak arch_register_cpu(int cpu)
 {
 	return register_cpu(&per_cpu(cpu_devices, cpu), cpu);
 }
+
+void __weak arch_unregister_cpu(int num)
+{
+	unregister_cpu(&per_cpu(cpu_devices, num));
+}
 #endif
 
 static void __init cpu_dev_register_generic(void)
-- 
2.30.2
