From: "Ashok Raj" <ashok.raj@intel.com>
Date: Sun, 25 Apr 2004 06:45:40 +0000
Subject: [RFC IA64 Hotplug] IA64 CPU Hotplug
Message-Id: <ORSMSX404FRaqbC8wSA0000016e@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

The following are a set of patches that are required to enable CPU hotplug
code for IA64. This has withstood stress testing with several make -j
running, + rcp/ftp network activity as well for over 24+ hrs. A brief
description of the patches that are going to follow is shown below. Please
take a look at the patches, and since this is the first wide distribution,
there could be several things that I might have overlooked or very silly
mistakes. Please take it for a test spin, and after I fix any more review
and feedback, I will request maintainers for inclusion as necessary.

Special thanks to Rusty for the relentless work on the base infrastructure
patches, and Vatsa the stress master for closing more holes as he discovers
them!.

Cheers,
Ashok Raj

CPU Hotplug support for IPF
---------------------------

The following set of patches enables CPU Hotplug support for IPF. This is
the second release and still long ways to go. Here is what is done so far in
terms of testing.

- stress testing with make -j and some network activity via rcp/ftp while
  cpu up/down is in progress.
- Tested with 2.6.5 tree from kernel.org
- start kernel with num_cpus=2 in a 4 way system, so we only start
  2 cpu's. Later echo 1 > /sys/devices/system/cpu/cpu2/online to kick
  the other cpu into action. 
- logical online/offline with stress has run over 24+ hrs without
panics/stalls
- each time before cpu_down() is invoked via echo 0 to proc file, the
serial, eth0, ioc0 and ioc1 on a tiger4 system were migrated manually to the
cpu that is going to be removed, just to stress test the migrate_irq patch.

Big TBD List
------------
- No support for boot cpu removal. (Basically timekeeper cpu dependency
needs to be removed) Will be added in future.
- Not tested on NUMA platforms, only tested with dig support, may require
minor changes. 
- Processor going down is still spinning in idle loop, need to make the
processor enter to BOOT_RENDEZ mode when __cpu_disable() is called. (Will be
done in subsequent release)
- Only local timer interrupt is shut during cpu_disable(), other local
interrupt sources should also be turned off.
- Some utilities like top needs to change. Currently they take sysconf
values for all online cpu's and assume they don't change.
- forcing irq affinity with a cpu, currently does not remember redirection
hint, as we don't rely on it for CPU hotplug. But this is required for the
non-hotplug case. This will be fixed in next release.

What is contained in each?
-----------------------------

p00001_core_kernel_init.patch
p00002_init_removal_ia64.patch
	Both these change __init to __devinit to support CPU hotplug. Some
	functions need to be present after boot and not freed as part of
	init section.
p00003_sysfs_ia64.patch
	Adds sysfs support for IA64/dig only under topology.c
p00004_hotcpu_ia64.patch
	Adds basic logical offline/online support for IPF. Cannot be used
	reliably without the migrate_irq.patch which is required to deal
	with iosapic and process pending interrupts without missing any.
p00005_ia64_palinfo.patch
	Adds /proc/pal/cpuX entries dynamically with hooks to cpu
notification. Also fixes bugs in the proc removal code that was never
functioning as its supposed to.
p00006_cpu_present.patch
	This patch adds a new mask cpu_present_map and associated macros.
This 	was added primarily because cpu_possible() is expected to never
change 	dynamically. Since several components size resources upfront during
boot based on all possible CPU's. Fixing all cases is hard and 	involves
more validation, so we added the new cpu_present macro which 	will only be
true if the cpu is physically present. Used when we bring 	a cpu up.
/proc/stats that utilities like top use now iterate only 	online cpu's
versus possible cpu's like before.
p00007_migrate_irq.patch
	Adds migration of irq for i/o sapic devices. Permits devices to keep
	functioning without start/stop device drivers. Handles case to 
	handle a possiblity of missed interrupt when the intr source is 
	masked. Expected to work with msi devices as well, if the controller
	function for disable/enable/set_affinity works correctly for msi 
	devices. At this time this patch has not been verified to work
correctly for MSI devices.



