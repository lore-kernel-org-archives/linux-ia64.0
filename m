From: Jan Kiszka <jan.kiszka@siemens.com>
Date: Thu, 20 Nov 2014 17:01:37 +0000
Subject: [PATCH v10 00/27] Add gdb python scripts as kernel debugging helpers
Message-Id: <cover.1416502923.git.jan.kiszka@siemens.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, Ben Widawsky <ben@bwidawsk.net>, Borislav Petkov <bp@suse.de>, Tatiana Al-Chueyr Martins <tatiana.alchueyr@gmail.com>, Daniel Thompson <daniel.thompson@linaro.org>, Daniel Wagner <daniel.wagner@bmw-carit.de>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Kay Sievers <kay@vrfy.org>, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.cz>, Pantelis Koukousoulas <pktoss@gmail.com>, Rob Landley <rob@landley.net>, Rusty Russell <rusty@rustcorp.com.au>, sparclinux@vger.kernel.org, Tony Luck <tony.luck@intel.com>

Hi Thomas,

as discussed earlier today, I'm sending out a fresh rebase of the gdb
scripts so that you can organize the next steps towards merge. Thanks
for this in advance!

Changes since v9:
 - rebase over recent Linux version
 - use a generator instead of iterator for task list,
   fixes thread-group iteration [Daniel Wagner]
 - apply generator scheme on other iterations
 - propose myself as maintainer

See http://lkml.indiana.edu/hypermail/linux/kernel/1210.0/01598.html for
the original description and

    git://git.kiszka.org/linux.git queues/gdb-scripts

for the latest version.

There is still some issue with gdb >= 7.8 when parsing symbols of kernel
modules, because I didn't deliver those folks the requested core dump of
gdb so far - done now. So up to version 7.7 remains recommended for the
time being.

Jan

CC: Daniel Thompson <daniel.thompson@linaro.org>
CC: Daniel Wagner <daniel.wagner@bmw-carit.de>
CC: "David S. Miller" <davem@davemloft.net>
CC: Fenghua Yu <fenghua.yu@intel.com>
Cc: Jan Kiszka <jan.kiszka@siemens.com>
CC: Kay Sievers <kay@vrfy.org>
CC: linux-doc@vger.kernel.org
CC: linux-ia64@vger.kernel.org
Cc: linux-kbuild@vger.kernel.org
CC: linux-kbuild@vger.kernel.org
Cc: Michal Marek <mmarek@suse.cz>
CC: Michal Marek <mmarek@suse.cz>
CC: Pantelis Koukousoulas <pktoss@gmail.com>
CC: Rob Landley <rob@landley.net>
CC: Rusty Russell <rusty@rustcorp.com.au>
CC: sparclinux@vger.kernel.org
CC: Tony Luck <tony.luck@intel.com>

Daniel Thompson (1):
  scripts/gdb: Ignore byte-compiled python files

Daniel Wagner (1):
  scripts/gdb: Use a generator instead of iterator for task list

Jan Kiszka (24):
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
  scripts/gdb: Convert ModuleList to generator function
  scripts/gdb: Convert CpuList to generator function
  scripts/gdb: Define maintainer

Pantelis Koukousoulas (1):
  scripts/gdb: Port to python3 / gdb7.7

 .gitignore                             |   1 +
 Documentation/gdb-kernel-debugging.txt | 160 +++++++++++++++++++++++++++++++
 MAINTAINERS                            |   5 +
 Makefile                               |   6 +-
 kernel/module.c                        |   9 +-
 lib/Kconfig.debug                      |  11 +++
 scripts/Makefile                       |   3 +-
 scripts/gdb/Makefile                   |   1 +
 scripts/gdb/linux/.gitignore           |   2 +
 scripts/gdb/linux/Makefile             |  11 +++
 scripts/gdb/linux/__init__.py          |   0
 scripts/gdb/linux/cpus.py              | 135 +++++++++++++++++++++++++++
 scripts/gdb/linux/dmesg.py             |  65 +++++++++++++
 scripts/gdb/linux/modules.py           | 103 ++++++++++++++++++++
 scripts/gdb/linux/symbols.py           | 166 +++++++++++++++++++++++++++++++++
 scripts/gdb/linux/tasks.py             | 100 ++++++++++++++++++++
 scripts/gdb/linux/utils.py             | 156 +++++++++++++++++++++++++++++++
 scripts/gdb/vmlinux-gdb.py             |  30 ++++++
 18 files changed, 960 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/gdb-kernel-debugging.txt
 create mode 100644 scripts/gdb/Makefile
 create mode 100644 scripts/gdb/linux/.gitignore
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
1.8.4.5

