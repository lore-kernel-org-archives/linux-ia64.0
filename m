From: Jan Kiszka <jan.kiszka@siemens.com>
Date: Mon, 05 Nov 2012 16:08:53 +0000
Subject: [PATCH 00/13] Add gdb python scripts as kernel debugging helpers
Message-Id: <cover.1352131729.git.jan.kiszka@siemens.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Kay Sievers <kay@vrfy.org>, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.cz>, sparclinux@vger.kernel.org, Tony Luck <tony.luck@intel.com>

Version 2 of this series is a rebase over 3.7-rc4 to resolve some minor
collision in the top-level makefile. Moreover, this implements automatic
symbol loading for kernel modules using silent breakpoints. See patch 3
for details.

Unless someone complains over this series or suggests a better workflow,
I'm planning to send a pull to Linus during the next merge window.


Here is the original intro for reference:

This adds the infrastructure and first tools that make kernel debugging
through gdb more comfortable. Since 7.0, gdb supports python scripting.
And this opens the doors to automate steps like the tedious loading of
module symbols at the right address, resolving per-cpu variables or even
retrieving the current kernel log without resuming an stopped target.

Many of the helpers naturally depend on the layout of structures or
internal mechanics of the kernel. So the best place to maintain such
things, keeping them consistent with the corresponding kernel is, well,
the kernel itself.

While these scripts have been originally developed for debugging via
QEMU/KVM, I've now also added the required bits for KGDB. Works fine,
but as QEMU/KVM tends to outperform KGDB it remains the recommendation
- when available.

There are two architecture dependencies so far, one regarding per-cpu,
the other regarding thread_info calculation. None of them I was able to
test on a target, so I'm counting on review/testing by the corresponding
communities.

This series should be considered the foundation of much more kernel
state exploration helper, e.g. around tasks, timers, locks, sockets -
I guess people will have even more ideas.

Hope it's useful!

PS: Also available via git://git.kiszka.org/linux.git queues/gdb-scripts

CC: "David S. Miller" <davem@davemloft.net>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: Kay Sievers <kay@vrfy.org>
CC: linux-ia64@vger.kernel.org
CC: linux-kbuild@vger.kernel.org
CC: Michal Marek <mmarek@suse.cz>
CC: sparclinux@vger.kernel.org
CC: Tony Luck <tony.luck@intel.com>

Jan Kiszka (13):
  scripts/gdb: Add infrastructure
  scripts/gdb: Add container_of helper and convenience function
  scripts/gdb: Add lx-symbols command
  scripts/gdb: Add get_target_endianness helper
  scripts/gdb: Add read_u16/32/64 helpers
  scripts/gdb: Add lx-dmesg command
  scripts/gdb: Add task iteration helper
  scripts/gdb: Add helper and convenience function to look up tasks
  scripts/gdb: Add is_target_arch helper
  scripts/gdb: Add internal helper and convenience function to retrieve
    thread_info
  scripts/gdb: Add get_gdbserver_type helper
  scripts/gdb: Add internal helper and convenience function for per-cpu
    lookup
  scripts/gdb: Add lx_current convenience function

 Makefile                   |    5 +-
 scripts/Makefile           |    3 +-
 scripts/gdb/Makefile       |    9 +++
 scripts/gdb/dmesg.py       |   63 +++++++++++++++++++++
 scripts/gdb/percpu.py      |   76 +++++++++++++++++++++++++
 scripts/gdb/symbols.py     |  133 +++++++++++++++++++++++++++++++++++++++++++
 scripts/gdb/task.py        |  108 +++++++++++++++++++++++++++++++++++
 scripts/gdb/utils.py       |  134 ++++++++++++++++++++++++++++++++++++++++++++
 scripts/gdb/vmlinux-gdb.py |   26 +++++++++
 9 files changed, 555 insertions(+), 2 deletions(-)
 create mode 100644 scripts/gdb/Makefile
 create mode 100644 scripts/gdb/dmesg.py
 create mode 100644 scripts/gdb/percpu.py
 create mode 100644 scripts/gdb/symbols.py
 create mode 100644 scripts/gdb/task.py
 create mode 100644 scripts/gdb/utils.py
 create mode 100644 scripts/gdb/vmlinux-gdb.py

-- 
1.7.3.4

