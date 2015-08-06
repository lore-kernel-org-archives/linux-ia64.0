From: Matthew Leach <matthew@mattleach.net>
Date: Thu, 06 Aug 2015 09:34:36 +0000
Subject: [BUG]: Intel uncore boot warning introduced in 4.1
Message-Id: <1438853676.3139.20.camel@mattleach.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kan Liang <kan.liang@intel.com>, Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hello,

Since upgrading to a 4.1 series kernel, I have been getting an odd
warning message from the kernel on boot, [1], as well as random freezes
after about 20-30 minutes of uptime.  I'm not sure if the two are
related, however.

I've bisected the kernel and found that commit [2] seems to introduce
the warning message.  I have checked on a v4.2-rc5 kernel and the
warning message is still there.

I am running a Lenovo thinkpad t440. See [3] for /proc/cpuinfo.

Thanks,
Matt

[1]: 
resource sanity check: requesting [mem 0xfed10000-0xfed15fff], which spans more than pnp 00:01 [mem 0xfed10000-0xfed13fff]
------------[ cut here ]------------
WARNING: CPU: 1 PID: 1 at arch/x86/mm/ioremap.c:202 __ioremap_caller+0x2b0/0x3a0()
Info: mapping multiple BARs. Your kernel is fine.
CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.1.0-rc6-ARCH-00156-g15c1247 #31
Hardware name: LENOVO 20B7A0HL00/20B7A0HL00, BIOS GJET79WW (2.29 ) 09/03/2014
 0000000000000000 000000008d90ee2d ffff880310117ad8 ffffffff81f31c90
 ffffffff8245b758 ffff880310117b30 ffff880310117b18 ffffffff810df57b
 00000000fed10000 ffffc90001b90000 00000000fed16000 0000000000006000
Call Trace:
 [<ffffffff81f31c90>] dump_stack+0x4c/0x6e
 [<ffffffff810df57b>] warn_slowpath_common+0x7b/0xc0
 [<ffffffff810df640>] warn_slowpath_fmt+0x50/0x70
 [<ffffffff81045040>] __ioremap_caller+0x2b0/0x3a0
 [<ffffffff810452e2>] ioremap_nocache+0x12/0x20
 [<ffffffff81025464>] snb_uncore_imc_init_box+0x74/0xb0
 [<ffffffff810236e0>] uncore_pci_probe+0xd0/0x220
 [<ffffffff814f85d0>] local_pci_probe+0x40/0xa0
 [<ffffffff814f9755>] ? pci_match_device+0xe5/0x110
 [<ffffffff814f9879>] pci_device_probe+0xf9/0x150
 [<ffffffff816f6219>] driver_probe_device+0x1f9/0x4b0
 [<ffffffff816f65a3>] __driver_attach+0x93/0xa0
 [<ffffffff816f6510>] ? __device_attach+0x40/0x40
 [<ffffffff816f4223>] bus_for_each_dev+0x73/0xc0
 [<ffffffff816f6689>] driver_attach+0x19/0x20
 [<ffffffff816f4e18>] bus_add_driver+0x168/0x240
 [<ffffffff816f6def>] driver_register+0x5f/0xf0
 [<ffffffff8259b44c>] ? uncore_types_exit+0x26/0x26
 [<ffffffff814f9af6>] __pci_register_driver+0x46/0x50
 [<ffffffff8259b514>] intel_uncore_init+0xc8/0x2ad
 [<ffffffff8259b44c>] ? uncore_types_exit+0x26/0x26
 [<ffffffff82591106>] do_one_initcall+0x195/0x1aa
 [<ffffffff82591277>] kernel_init_freeable+0x15c/0x1f8
 [<ffffffff81f2dd50>] ? rest_init+0x90/0x90
 [<ffffffff81f2dd59>] kernel_init+0x9/0xf0
 [<ffffffff81f3bb92>] ret_from_fork+0x42/0x70
 [<ffffffff81f2dd50>] ? rest_init+0x90/0x90
---[ end trace 29e0f99deb80a845 ]---

[2]: 8cf1a3de97804b047973dd44cfacdc1930da8403

[3]:
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 69
model name      : Intel(R) Core(TM) i5-4300U CPU @ 1.90GHz
stepping        : 1
microcode       : 0x1c
cpu MHz         : 800.000
cache size      : 3072 KB
physical id     : 0
siblings        : 4
core id         : 0
cpu cores       : 2
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt
bugs            :
bogomips        : 4990.54
clflush size    : 64
cache_alignment : 64
address sizes   : 39 bits physical, 48 bits virtual
power management:

[repeated 3 times]

