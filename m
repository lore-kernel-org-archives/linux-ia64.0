From: Magnus Damm <magnus@valinux.co.jp>
Date: Mon, 05 Feb 2007 06:43:42 +0000
Subject: [PATCH] kexec: Fix CONFIG_SMP=n compilation V2 (ia64)
Message-Id: <20070205064342.21398.97736.sendpatchset@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070201163320.eb4fa2c7.akpm@osdl.org>
In-Reply-To: <20070201163320.eb4fa2c7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, jlan@sgi.com, nanhai.zou@intel.com, fastboot@lists.osdl.org, linux-kernel@vger.kernel.org, Magnus Damm <magnus@valinux.co.jp>, horms@verge.net.au, magnus.damm@gmail.com

kexec: Fix CONFIG_SMP=n compilation V2 (ia64)

Kexec support for 2.6.20 on ia64 does not build properly using a config
made up by CONFIG_SMP=n and CONFIG_HOTPLUG_CPU=n:

  CC      arch/ia64/kernel/machine_kexec.o
arch/ia64/kernel/machine_kexec.c: In function `machine_shutdown':
arch/ia64/kernel/machine_kexec.c:77: warning: implicit declaration of function `cpu_down'
  AS      arch/ia64/kernel/relocate_kernel.o
  CC      arch/ia64/kernel/crash.o
arch/ia64/kernel/crash.c: In function `kdump_cpu_freeze':
arch/ia64/kernel/crash.c:139: warning: implicit declaration of function `ia64_jump_to_sal'
arch/ia64/kernel/crash.c:139: error: `sal_boot_rendez_state' undeclared (first use in this function)
arch/ia64/kernel/crash.c:139: error: (Each undeclared identifier is reported only once
arch/ia64/kernel/crash.c:139: error: for each function it appears in.)
arch/ia64/kernel/crash.c: At top level:
arch/ia64/kernel/crash.c:84: warning: 'kdump_wait_cpu_freeze' defined but not used
make[1]: *** [arch/ia64/kernel/crash.o] Error 1
make: *** [arch/ia64/kernel] Error 2

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 Applies on top of 2.6.20.

 arch/ia64/kernel/crash.c         |   11 +++++++----
 arch/ia64/kernel/machine_kexec.c |    2 ++
 2 files changed, 9 insertions(+), 4 deletions(-)

--- 0002/arch/ia64/kernel/crash.c
+++ work/arch/ia64/kernel/crash.c	2007-02-02 20:31:18.000000000 +0900
@@ -79,6 +79,7 @@ crash_save_this_cpu()
 	final_note(buf);
 }
 
+#ifdef CONFIG_SMP
 static int
 kdump_wait_cpu_freeze(void)
 {
@@ -91,6 +92,7 @@ kdump_wait_cpu_freeze(void)
 	}
 	return 1;
 }
+#endif
 
 void
 machine_crash_shutdown(struct pt_regs *pt)
@@ -132,11 +134,12 @@ kdump_cpu_freeze(struct unw_frame_info *
 	atomic_inc(&kdump_cpu_freezed);
 	kdump_status[cpuid] = 1;
 	mb();
-	if (cpuid = 0) {
-		for (;;)
-			cpu_relax();
-	} else
+#ifdef CONFIG_HOTPLUG_CPU
+	if (cpuid != 0)
 		ia64_jump_to_sal(&sal_boot_rendez_state[cpuid]);
+#endif
+	for (;;)
+		cpu_relax();
 }
 
 static int
--- 0002/arch/ia64/kernel/machine_kexec.c
+++ work/arch/ia64/kernel/machine_kexec.c	2007-02-02 20:56:24.000000000 +0900
@@ -70,12 +70,14 @@ void machine_kexec_cleanup(struct kimage
 
 void machine_shutdown(void)
 {
+#ifdef CONFIG_HOTPLUG_CPU
 	int cpu;
 
 	for_each_online_cpu(cpu) {
 		if (cpu != smp_processor_id())
 			cpu_down(cpu);
 	}
+#endif
 	kexec_disable_iosapic();
 }
 
