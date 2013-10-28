From: Jan Kiszka <jan.kiszka@Siemens.com>
Date: Mon, 28 Oct 2013 08:58:37 +0000
Subject: [PATCH v6 00/21] Add gdb python scripts as kernel debugging helpers
Message-Id: <cover.1382950737.git.jan.kiszka@siemens.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, Ben Widawsky <ben@bwidawsk.net>, Borislav Petkov <bp@suse.de>, Tatiana Al-Chueyr Martins <tatiana.alchueyr@gmail.com>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Kay Sievers <kay@vrfy.org>, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.cz>, Rob Landley <rob@landley.net>, sparclinux@vger.kernel.org, Tony Luck <tony.luck@intel.com>

It's been a while since my last update of these patches. This one is
mostly about cleaning up and making some details more convenient:
 - proper registration of module data segments to access module
   variables - this obsoletes lx_modvar again
 - stable breakpoint target on do_init_module in order to track module
   loading more reliably from the debugger
 - internal refactoring with the aim to "pythonize" the scripts (credits
   for all valuable suggestions belong to Tatiana, many thanks, for
   improper implementations to me)

See http://lkml.indiana.edu/hypermail/linux/kernel/1210.0/01598.html for
the original description and

    git://git.kiszka.org/linux.git queues/gdb-scripts

for the latest version.

Jan

CC: "David S. Miller" <davem@davemloft.net>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: Kay Sievers <kay@vrfy.org>
CC: linux-doc@vger.kernel.org
CC: linux-ia64@vger.kernel.org
CC: linux-kbuild@vger.kernel.org
CC: Michal Marek <mmarek@suse.cz>
CC: Rob Landley <rob@landley.net>
CC: sparclinux@vger.kernel.org
CC: Tony Luck <tony.luck@intel.com>

Jan Kiszka (21):
  scripts/gdb: Add infrastructure
  scripts/gdb: Add cache for type objects
  scripts/gdb: Add container_of helper and convenience function
  scripts/gdb: Add module iteration class
  scripts/gdb: Add lx-symbols command
  module: Do not inline do_init_module
  scripts/gdb: Add automatic symbol reloading on module insertion
  scripts/gdb: Add internal helper and convenience function to look up a
    module
  scripts/gdb: Add get_target_endianness helper
  scripts/gdb: Add read_u16/32/64 helpers
  scripts/gdb: Add lx-dmesg command
  scripts/gdb: Add task iteration class
  scripts/gdb: Add helper and convenience function to look up tasks
  scripts/gdb: Add is_target_arch helper
  scripts/gdb: Add internal helper and convenience function to retrieve
    thread_info
  scripts/gdb: Add get_gdbserver_type helper
  scripts/gdb: Add internal helper and convenience function for per-cpu
    lookup
  scripts/gdb: Add lx_current convenience function
  scripts/gdb: Add class to iterate over CPU masks
  scripts/gdb: Add lx-lsmod command
  scripts/gdb: Add basic documentation

 Documentation/gdb-kernel-debugging.txt | 159 +++++++++++++++++++++++++++++++
 Makefile                               |   5 +-
 kernel/module.c                        |   9 +-
 scripts/Makefile                       |   3 +-
 scripts/gdb/Makefile                   |  11 +++
 scripts/gdb/linux/Makefile             |   9 ++
 scripts/gdb/linux/__init__.py          |   0
 scripts/gdb/linux/cpus.py              | 139 +++++++++++++++++++++++++++
 scripts/gdb/linux/dmesg.py             |  64 +++++++++++++
 scripts/gdb/linux/modules.py           | 111 ++++++++++++++++++++++
 scripts/gdb/linux/symbols.py           | 166 +++++++++++++++++++++++++++++++++
 scripts/gdb/linux/tasks.py             | 108 +++++++++++++++++++++
 scripts/gdb/linux/utils.py             | 156 +++++++++++++++++++++++++++++++
 scripts/gdb/vmlinux-gdb.py             |  30 ++++++
 14 files changed, 966 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/gdb-kernel-debugging.txt
 create mode 100644 scripts/gdb/Makefile
 create mode 100644 scripts/gdb/linux/Makefile
 create mode 100644 scripts/gdb/linux/__init__.py
 create mode 100644 scripts/gdb/linux/cpus.py
 create mode 100644 scripts/gdb/linux/dmesg.py
 create mode 100644 scripts/gdb/linux/modules.py
 create mode 100644 scripts/gdb/linux/symbols.py
 create mode 100644 scripts/gdb/linux/tasks.py
 create mode 100644 scripts/gdb/linux/utils.py
 create mode 100644 scripts/gdb/vmlinux-gdb.py

-- 
1.8.1.1.298.ge7eed54

