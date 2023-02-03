From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:12 +0000
Subject: [RFC PATCH 01/32] ia64: Fix build error due to switch case label appearing next to declaration
Message-Id: <20230203135043.409192-2-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Since commit aa06a9bd8533 ("ia64: fix clock_getres(CLOCK_MONOTONIC) to
report ITC frequency"), gcc 10.1.0 fails to build ia64 with the gnomic:
| ../arch/ia64/kernel/sys_ia64.c: In function 'ia64_clock_getres':
| ../arch/ia64/kernel/sys_ia64.c:189:3: error: a label can only be part of a statement and a declaration is not a statement
|   189 |   s64 tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);

This line appears immediately after a case label in a switch.

Move the declarations out of the case, to the top of the function.

Signed-off-by: James Morse <james.morse@arm.com>
---
This patch was previously posted as a fix here:
https://www.spinics.net/lists/linux-ia64/msg21920.html
Its included here to keep the kbuild robot quiet.

 arch/ia64/kernel/sys_ia64.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
index f6a502e8f02c..6e948d015332 100644
--- a/arch/ia64/kernel/sys_ia64.c
+++ b/arch/ia64/kernel/sys_ia64.c
@@ -170,6 +170,9 @@ ia64_mremap (unsigned long addr, unsigned long old_len, unsigned long new_len, u
 asmlinkage long
 ia64_clock_getres(const clockid_t which_clock, struct __kernel_timespec __user *tp)
 {
+	struct timespec64 rtn_tp;
+	s64 tick_ns;
+
 	/*
 	 * ia64's clock_gettime() syscall is implemented as a vdso call
 	 * fsys_clock_gettime(). Currently it handles only
@@ -185,8 +188,8 @@ ia64_clock_getres(const clockid_t which_clock, struct __kernel_timespec __user *
 	switch (which_clock) {
 	case CLOCK_REALTIME:
 	case CLOCK_MONOTONIC:
-		s64 tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);
-		struct timespec64 rtn_tp = ns_to_timespec64(tick_ns);
+		tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);
+		rtn_tp = ns_to_timespec64(tick_ns);
 		return put_timespec64(&rtn_tp, tp);
 	}
 
-- 
2.30.2
