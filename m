From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Date: Wed, 13 Sep 2017 09:17:54 +0000
Subject: [PATCH v9] ACPI / init: Invoke early ACPI initialization earlier
Message-Id: <1505294274-441-1-git-send-email-douly.fnst@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1505293975-26005-1-git-send-email-douly.fnst@cn.fujitsu.com>
In-Reply-To: <1505293975-26005-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Zheng, Lv" <lv.zheng@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, yinghai@kernel.org, bhe@redhat.com, bp@alien8.de

Linux uses acpi_early_init() to put the ACPI table management into the
late stage from the early stage. This two stages are different. the
mapped ACPI tables in early stage is temporary and should be unmapped,
but in late stage, it is permanent and don't need to be unmapped.

Originally, mapping and parsing the DMAR table should be in the late stage.
However, Initializing interrupt delivery mode earlier will move it into
the early stage. This causes an ACPI error warning when Linux reallocates
the ACPI root tables.

Commit b064a8fa77df ("ACPI / init: Switch over platform to the ACPI mode
later") splits the ACPI early initialization code into acpi_early_init()
and acpi_subsystem_init(). This makes acpi_early_init() more independently

So, invoke acpi_early_init() earlier before late_time_init(), Keep the DMAR
be mapped and parsed in late stage like before.

Reported-by: Xiaolong Ye <xiaolong.ye@intel.com>
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: linux-acpi@vger.kernel.org
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Zheng, Lv <lv.zheng@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: yinghai@kernel.org
Cc: bhe@redhat.com
Cc: bp@alien8.de
---
 init/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/init/main.c b/init/main.c
index 0ee9c686..2fb98a4 100644
--- a/init/main.c
+++ b/init/main.c
@@ -664,12 +664,12 @@ asmlinkage __visible void __init start_kernel(void)
 	debug_objects_mem_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
+	acpi_early_init();
 	if (late_time_init)
 		late_time_init();
 	calibrate_delay();
 	pidmap_init();
 	anon_vma_init();
-	acpi_early_init();
 #ifdef CONFIG_X86
 	if (efi_enabled(EFI_RUNTIME_SERVICES))
 		efi_enter_virtual_mode();
-- 
2.5.5



