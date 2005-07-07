From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Jul 2005 16:01:13 +0000
Subject: git pull on ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03D9270D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	
rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/sn/include/pci/pcibr_provider.h |  151 -------
 arch/ia64/sn/include/pci/pic.h            |  261 ------------
 arch/ia64/sn/include/pci/tiocp.h          |  256 ------------
 arch/ia64/kernel/Makefile                 |    1 
 arch/ia64/kernel/acpi.c                   |    4 
 arch/ia64/kernel/numa.c                   |   57 ++
 arch/ia64/kernel/signal.c                 |    2 
 arch/ia64/kernel/smpboot.c                |   41 --
 arch/ia64/kernel/traps.c                  |    6 
 arch/ia64/mm/discontig.c                  |  432 +++++++++------------
 arch/ia64/mm/init.c                       |    3 
 arch/ia64/sn/include/xtalk/hubdev.h       |    2 
 arch/ia64/sn/kernel/io_init.c             |  185 +++++----
 arch/ia64/sn/kernel/irq.c                 |  251 ++++++------
 arch/ia64/sn/kernel/setup.c               |   13 
 arch/ia64/sn/pci/pci_dma.c                |    3 
 arch/ia64/sn/pci/pcibr/pcibr_ate.c        |    2 
 arch/ia64/sn/pci/pcibr/pcibr_dma.c        |   15 
 arch/ia64/sn/pci/pcibr/pcibr_provider.c   |   48 ++
 arch/ia64/sn/pci/pcibr/pcibr_reg.c        |    8 
 arch/ia64/sn/pci/tioca_provider.c         |    3 
 drivers/pci/hotplug/Kconfig               |    5 
 drivers/pci/hotplug/Makefile              |    1 
 drivers/pci/hotplug/sgi_hotplug.c         |  611
++++++++++++++++++++++++++++++
 drivers/pci/search.c                      |    1 
 include/asm-ia64/sn/arch.h                |    1 
 include/asm-ia64/sn/intr.h                |    6 
 include/asm-ia64/sn/pcibr_provider.h      |  159 +++++++
 include/asm-ia64/sn/pcidev.h              |   16 
 include/asm-ia64/sn/pic.h                 |  261 ++++++++++++
 include/asm-ia64/sn/sn_cpuid.h            |    5 
 include/asm-ia64/sn/sn_sal.h              |   39 -
 include/asm-ia64/sn/tiocp.h               |  256 ++++++++++++
 33 files changed, 1906 insertions(+), 1199 deletions(-)


commit 283c7f6ac6adb57e7dd13cdbc8d60b6ea4de6faf
tree 53ce99a2373134c174f8df4f3729fcb4f11fb44e
parent e07d01e0aeba905aeca6e0ae612943417d396a0f
author Prarit Bhargava <prarit@sgi.com> 1120688953 -0700
committer Tony Luck <tony.luck@intel.com> 1120688953 -0700

[IA64] hotplug/ia64: SN Hotplug Driver - new SN PROM version code

This patch is a rewrite of the code to check the PROM version.  The
current
code has some deficiences in the way PROM comparisons were made.  The
minimum
value of PROM that will boot has also been changed to 4.04.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 2ba3e3e65cf182436757ba13ea8d564e2950fb56
tree 7546a5141398e8ecaa493a58a4ca8af11deaf04d
parent 7fe4c1b16854f0440939c62b8102cbf5c75e7cdc
author Keith Owens <kaos@sgi.com> 1120197180 -0700
committer Tony Luck <tony.luck@intel.com> 1120689075 -0700

[IA64] restore_sigcontext is not preempt safe

restore_sigcontext calls ia64_set_local_fpu_owner() which requires that
preempt be disabled.

Signed-off-by: Keith Owens <kaos@sgi.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 564601a5d12f93fdde04c6bc5b097b95e7752a46
tree 7ecd89b4eea6c626eb0726a5f7cf16e6e0f93b6e
parent af25e94d4dcfb9608846242fabdd4e6014e5c9f0
author bob.picco <bob.picco@hp.com> 1120150320 -0700
committer Tony Luck <tony.luck@intel.com> 1120689930 -0700

[IA64] memory-less-nodes repost

I reworked how nodes with only CPUs are treated.  The patch below seems
simpler to me and has eliminated the complicated routine
reassign_cpu_only_nodes.  There isn't any longer the requirement
to modify ACPI NUMA information which was in large part the
complexity introduced in reassign_cpu_only_nodes. 

This patch will produce a different number of nodes. For example,
reassign_cpu_only_nodes would reduce two CPUonly nodes and one memory
node
configuration to one memory+CPUs node configuration.  This patch
doesn't change the number of nodes which means the user will see three.
Two
nodes without memory and one node with all the memory.

While doing this patch, I noticed that early_nr_phys_cpus_node isn't
serving
any useful purpose.  It is called once in find_pernode_space but the
value
isn't used to computer pernode space.  

Signed-off-by: bob.picco <bob.picco@hp.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 6f354b014b51716166f13f68b29212d3c44ed2c4
tree 396c09a5d519630a53652a1187bb85fceba82cee
parent 283c7f6ac6adb57e7dd13cdbc8d60b6ea4de6faf
author Prarit Bhargava <prarit@sgi.com> 1120688993 -0700
committer Tony Luck <tony.luck@intel.com> 1120688993 -0700

[IA64] hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code

This patch is the SGI hotplug driver and additional changes required for
the driver.  These modifications include changes to the SN io_init.c
code
for memory management, the inclusion of new SAL calls to enable and
disable
PCI slots, and a hotplug-style driver.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 7fe4c1b16854f0440939c62b8102cbf5c75e7cdc
tree 4ec5ef085c011a582454f4a6df2705f4ce339ca3
parent 6f354b014b51716166f13f68b29212d3c44ed2c4
author Prarit Bhargava <prarit@sgi.com> 1120689025 -0700
committer Tony Luck <tony.luck@intel.com> 1120689025 -0700

[IA64] hotplug/ia64: SN Hotplug Driver - PREEMPT/pcibus_info fix

This patch fixes an issue with the PROM and a kernel running with
CONFIG_PREEMPT enabled.  When CONFIG_PREEMPT is enabled, the size of a
spinlock_t changes -- resulting in the PROM writing to an incorrect
location.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 8d7e35174d02ce76e910365acaaefc281a0b72a0
tree 4445375bbf8c08f8032c5a013374777931949285
parent 564601a5d12f93fdde04c6bc5b097b95e7752a46
author Tony Luck <tony.luck@intel.com> 1120699090 -0700
committer Tony Luck <tony.luck@intel.com> 1120699090 -0700

[IA64] fix generic/up builds

Jesse Barnes provided the original version of this patch months ago, but
other changes kept conflicting with it, so it got deferred.  Greg
Edwards
dug it out of obscurity just over a week ago, and almost immediately
another conflicting patch appeared (Bob Picco's memory-less nodes).

I've resolved the conflicts and got it running again.  CONFIG_SGI_TIOCX
is set to "y" in defconfig, which causes a Tiger to not boot (oops in
tiocx_init).  But that can be resolved later ... get this in now before
it
gets stale again.

Signed-off-by: Tony Luck <tony.luck@intel.com>

commit af25e94d4dcfb9608846242fabdd4e6014e5c9f0
tree f311db4563cb7f101520c737965e3d2180fcda67
parent 67d340f440f389e9d56201fb7c7aaa92f262feb1
author  <> 1120285620 -0700
committer Tony Luck <tony.luck@intel.com> 1120689895 -0700

[IA64] Make ia64 die() preempt safe

Signed-off-by: Keith Owens <kaos@sgi.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

commit c13cf3714fc84ad2fd65771aa08e47c95a9f26ef
tree f3fdd5f81fc0e39029f7cc6c8e4f41d6a736a4de
parent cb4cb2cb9b0b14bdf2fc7125e099ed7e818cea42
author Prarit Bhargava <prarit@sgi.com> 1120688811 -0700
committer Tony Luck <tony.luck@intel.com> 1120688811 -0700

[IA64] hotplug/ia64: SN Hotplug Driver: moving of header files

This patch moves header files out of the arch/ia64/sn directories and
into
include/asm-ia64/sn.  These files were being included by other
subsystems
and should be under include/asm-ia64/sn.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

commit cb4cb2cb9b0b14bdf2fc7125e099ed7e818cea42
tree 11e110ce3201e0cbd3e30f1d4a1b0dc6ebe19bfa
parent bd53d1270f51c6cfb53b06c8f93fd42327871d6b
author Prarit Bhargava <prarit@sgi.com> 1120687184 -0700
committer Tony Luck <tony.luck@intel.com> 1120687184 -0700

[IA64] hotplug/ia64: SN Hotplug Driver: SN IRQ Fixes

This patch  fixes the SN IRQ code such that cpu affinity and
Hotplug can modify IRQ values.  The sn_irq_info structures are now
locked
using a RCU lock mechanism to avoid lock contention in the lost
interrupt
WAR code.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

commit e07d01e0aeba905aeca6e0ae612943417d396a0f
tree 5d445ad1803389844ccf9a4fcb9ec160ae554fd7
parent c13cf3714fc84ad2fd65771aa08e47c95a9f26ef
author Prarit Bhargava <prarit@sgi.com> 1120688920 -0700
committer Tony Luck <tony.luck@intel.com> 1120688920 -0700

[IA64] hotplug/ia64: SN Hotplug Driver - pci_find_next_bus export

The pci_find_next_bus function is listed as being exported to drivers.
It is
not EXPORT_SYMBOL'd.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>
