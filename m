From: Borislav Petkov <bp@alien8.de>
Date: Wed, 27 Sep 2017 09:02:31 +0000
Subject: Re: [PATCH v9] ACPI / init: Invoke early ACPI initialization earlier
Message-Id: <20170927090231.god7clzl6cyoxoxa@pd.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <1505293975-26005-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <1505294274-441-1-git-send-email-douly.fnst@cn.fujitsu.com>
In-Reply-To: <1505294274-441-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Zheng, Lv" <lv.zheng@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, yinghai@kernel.org, bhe@redhat.com

On Wed, Sep 13, 2017 at 05:17:54PM +0800, Dou Liyang wrote:
> Linux uses acpi_early_init() to put the ACPI table management into the
> late stage from the early stage. This two stages are different. the
> mapped ACPI tables in early stage is temporary and should be unmapped,
> but in late stage, it is permanent and don't need to be unmapped.
> 
> Originally, mapping and parsing the DMAR table should be in the late stage.
> However, Initializing interrupt delivery mode earlier will move it into
> the early stage. This causes an ACPI error warning when Linux reallocates
> the ACPI root tables.
> 
> Commit b064a8fa77df ("ACPI / init: Switch over platform to the ACPI mode
> later") splits the ACPI early initialization code into acpi_early_init()
> and acpi_subsystem_init(). This makes acpi_early_init() more independently
> 
> So, invoke acpi_early_init() earlier before late_time_init(), Keep the DMAR
> be mapped and parsed in late stage like before.
> 
> Reported-by: Xiaolong Ye <xiaolong.ye@intel.com>
> Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
> Cc: linux-acpi@vger.kernel.org
> Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
> Cc: Zheng, Lv <lv.zheng@intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: yinghai@kernel.org
> Cc: bhe@redhat.com
> Cc: bp@alien8.de
> ---
>  init/main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/init/main.c b/init/main.c
> index 0ee9c686..2fb98a4 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -664,12 +664,12 @@ asmlinkage __visible void __init start_kernel(void)
>  	debug_objects_mem_init();
>  	setup_per_cpu_pageset();
>  	numa_policy_init();
> +	acpi_early_init();
>  	if (late_time_init)
>  		late_time_init();
>  	calibrate_delay();
>  	pidmap_init();
>  	anon_vma_init();
> -	acpi_early_init();
>  #ifdef CONFIG_X86
>  	if (efi_enabled(EFI_RUNTIME_SERVICES))
>  		efi_enter_virtual_mode();
> -- 

Tested-by: Borislav Petkov <bp@suse.de>

This one fixes the early ioremap leak check I get here with tip/master:

Debug warning: early ioremap leak of 1 areas detected.
please boot with early_ioremap_debug and report the dmesg.
------------[ cut here ]------------
WARNING: CPU: 3 PID: 1 at mm/early_ioremap.c:98 check_early_ioremap_leak+0x31/0x39
Modules linked in:
CPU: 3 PID: 1 Comm: swapper/0 Not tainted 4.14.0-rc2+ #1
Hardware name: LENOVO 2320CTO/2320CTO, BIOS G2ET86WW (2.06 ) 11/13/2012
task: ffff8802138e0000 task.stack: ffffc90000c90000
RIP: 0010:check_early_ioremap_leak+0x31/0x39
RSP: 0000:ffffc90000c93ea8 EFLAGS: 00010296
RAX: 0000000000000071 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffff8802138e0000 RSI: 0000000000000001 RDI: 0000000000000282
RBP: ffffffff82089d8e R08: ffffffff810cc9c5 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff82182d30
R13: 0000000000000008 R14: ffffffff8205d7f6 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88021d380000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 0000000001c10001 CR4: 00000000001606e0
Call Trace:
 do_one_initcall+0x4b/0x18c
 kernel_init_freeable+0x120/0x1a2
 ? rest_init+0xd0/0xd0
 kernel_init+0xa/0x100
 ret_from_fork+0x2a/0x40
Code: d2 31 c0 48 83 3c d5 a0 3a 11 82 00 74 02 ff c0 48 ff c2 48 83 fa 08 75 ea 85 c0 74 15 89 c6 48 c7 c7 20 c7 a6 81 e8 bc 2b 04 ff <0f> ff b8 01 00 00 00 c3 0f 1f 44 00 00 41 57 48 89 f1 41 56 41 
---[ end trace f7d67c4805284a92 ]---

Booting with early_ioremap_debug showed this last ioremap call in the Intel
iommu code ioremapping the DMAR table but not unmapping it:

__early_ioremap(dafdb000, 00001000) [0] => 00000000 + ffffffffff200000
------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at mm/early_ioremap.c:161 __early_ioremap+0x150/0x17f
Modules linked in:
CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.14.0-rc2+ #2
Hardware name: LENOVO 2320CTO/2320CTO, BIOS G2ET86WW (2.06 ) 11/13/2012
task: ffffffff81c15500 task.stack: ffffffff81c00000
RIP: 0010:__early_ioremap+0x150/0x17f
RSP: 0000:ffffffff81c03d70 EFLAGS: 00010282
RAX: 0000000000000046 RBX: 00000000dafda000 RCX: 0000000000000000
RDX: 0000000000000002 RSI: 0000000000000001 RDI: 0000000000000001
RBP: 0000000000000001 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 00000000dafdb000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88021d200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff88021e5ff000 CR3: 0000000001c10001 CR4: 00000000000606b0
Call Trace:
 acpi_tb_acquire_table+0x39/0x64
 acpi_tb_validate_table+0x21/0x33
 acpi_tb_get_table+0x25/0x5e
 acpi_get_table+0x59/0x82
 dmar_table_detect+0x1a/0x43
 dmar_table_init+0x73/0x13e
 ? dmar_free_dev_scope+0xe0/0xe0
 ? intel_iommu_setup+0x211/0x211
 ? iommu_calculate_agaw+0x20/0x20
 ? dmar_walk_remapping_entries+0x170/0x170
 ? detect_intel_iommu+0xca/0xca
 intel_prepare_irq_remapping+0x3a/0x22a
 irq_remapping_prepare+0x1a/0x2a
 enable_IR_x2apic+0x21/0x198
 default_setup_apic_routing+0x12/0x6f
 apic_intr_mode_init+0x14b/0x181
 x86_late_time_init+0x11/0x16
 start_kernel+0x3ae/0x44c
 secondary_startup_64+0xa5/0xa5
Code: 1a 74 2b 42 ff 34 ed 20 3a 11 82 45 89 f0 48 c7 c6 90 df 81 81 48 c7 c7 c0 c7 a6 81 4c 8b 4c 24 08 48 8b 4c 24 10 e8 64 2a 04 ff <0f> ff 58 48 8b 04 24 4a 03 04 ed 20 3a 11 82 4a 89 04 ed a0 3a 
---[ end trace 52caafcde4fdbc68 ]---
DMAR: Host address width 36
DMAR: DRHD base: 0x000000fed90000 flags: 0x0
DMAR: dmar0: reg_base_addr fed90000 ver 1:0 cap c0000020e60262 ecap f0101a
DMAR: DRHD base: 0x000000fed91000 flags: 0x1
DMAR: dmar1: reg_base_addr fed91000 ver 1:0 cap c9008020660262 ecap f0105a
DMAR: RMRR base: 0x000000da2ba000 end: 0x000000da2d0fff
DMAR: RMRR base: 0x000000db800000 end: 0x000000df9fffff
DMAR-IR: IOAPIC id 2 under DRHD base  0xfed91000 IOMMU 1
DMAR-IR: HPET id 0 under DRHD base 0xfed91000
DMAR-IR: Queued invalidation will be enabled to support x2apic and Intr-remapping.
DMAR-IR: Enabled IRQ remapping in x2apic mode
x2apic enabled
Switched APIC routing to cluster x2apic.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
