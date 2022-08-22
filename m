From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 22 Aug 2022 02:15:14 +0000
Subject: [RFC 04/10] cpu/hotplug: Check the capability of kexec quick reboot
Message-Id: <20220822021520.6996-5-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220822021520.6996-1-kernelfans@gmail.com>
In-Reply-To: <20220822021520.6996-1-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Price <steven.price@arm.com>, Kuppuswamy Sathyanarayanan <sathyanarayanan.kuppuswamy@linux.intel.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Frederic Weisbecker <frederic@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Peter Zijlstra <peterz@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>

The kexec quick reboot needs each involved cpuhp_step to run in
parallel.

There are lots of teardown cpuhp_step, but not all of them belong to
arm/arm64/riscv kexec reboot path. So introducing a member
'support_kexec_parallel' in the struct cpuhp_step to signal whether the
teardown supports parallel or not. If a cpuhp_step is used in kexec
reboot, then it needs to support parallel to enable the quick reboot.

The function check_quick_reboot() checks all teardown cpuhp_steps and
report those unsupported if any.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Price <steven.price@arm.com>
Cc: Kuppuswamy Sathyanarayanan <sathyanarayanan.kuppuswamy@linux.intel.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Frederic Weisbecker <frederic@kernel.org>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>
Cc: Palmer Dabbelt <palmer@dabbelt.com>
Cc: Albert Ou <aou@eecs.berkeley.edu>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: linux-arm-kernel@lists.infradead.org
To: linux-ia64@vger.kernel.org
To: linux-riscv@lists.infradead.org
To: linux-kernel@vger.kernel.org
---
 include/linux/cpuhotplug.h |  2 ++
 kernel/cpu.c               | 28 +++++++++++++++++++++++++++-
 2 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index f61447913db9..73093fc15aec 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -374,6 +374,8 @@ static inline int cpuhp_setup_state_multi(enum cpuhp_state state,
 				   (void *) teardown, true);
 }
 
+void cpuhp_set_step_parallel(enum cpuhp_state state);
+
 int __cpuhp_state_add_instance(enum cpuhp_state state, struct hlist_node *node,
 			       bool invoke);
 int __cpuhp_state_add_instance_cpuslocked(enum cpuhp_state state,
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 94ab2727d6bb..1261c3f3be51 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -137,6 +137,9 @@ struct cpuhp_step {
 	/* public: */
 	bool			cant_stop;
 	bool			multi_instance;
+#ifdef CONFIG_SHUTDOWN_NONBOOT_CPUS
+	bool			support_kexec_parallel;
+#endif
 };
 
 static DEFINE_MUTEX(cpuhp_state_mutex);
@@ -147,6 +150,14 @@ static struct cpuhp_step *cpuhp_get_step(enum cpuhp_state state)
 	return cpuhp_hp_states + state;
 }
 
+#ifdef CONFIG_SHUTDOWN_NONBOOT_CPUS
+void cpuhp_set_step_parallel(enum cpuhp_state state)
+{
+	cpuhp_hp_states[state].support_kexec_parallel = true;
+}
+EXPORT_SYMBOL(cpuhp_set_step_parallel);
+#endif
+
 static bool cpuhp_step_empty(bool bringup, struct cpuhp_step *step)
 {
 	return bringup ? !step->startup.single : !step->teardown.single;
@@ -1347,7 +1358,22 @@ static void takedown_cpus_no_rollback(struct cpumask *cpus)
 
 static bool check_quick_reboot(void)
 {
-	return false;
+	struct cpuhp_step *step;
+	enum cpuhp_state state;
+	bool ret = true;
+
+	for (state = CPUHP_ONLINE; state >= CPUHP_AP_OFFLINE; state--) {
+		step = cpuhp_get_step(state);
+		if (step->teardown.single = NULL)
+			continue;
+		if (step->support_kexec_parallel = false) {
+			pr_info("cpuhp state:%d, %s, does not support cpudown in parallel\n",
+					state, step->name);
+			ret = false;
+		}
+	}
+
+	return ret;
 }
 
 static struct cpumask kexec_ap_map;
-- 
2.31.1
