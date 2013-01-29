From: Jan Kiszka <jan.kiszka@siemens.com>
Date: Tue, 29 Jan 2013 12:37:43 +0000
Subject: [PATCH v5 00/20] Add gdb python scripts as kernel debugging helpers
Message-Id: <cover.1359463075.git.jan.kiszka@siemens.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, Ben Widawsky <ben@bwidawsk.net>, Borislav Petkov <bp@alien8.de>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Kay Sievers <kay@vrfy.org>, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.cz>, Rob Landley <rob@landley.net>, sparclinux@vger.kernel.org, Tony Luck <tony.luck@intel.com>

Version 5 comes with the following changes:
 - moved tutorial into Documentation/gdb-kernel-debugging.txt
 - improved caching of gdb.Type objects, ensure they are in sync with
   currently loaded symbols
 - added new functions and commands
    - lx_module -- Find module by name and return the module variable
    - lx_modvar -- Return global variable of a module
    - lx-lsmod -- List currently loaded modules

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

Jan Kiszka (20):
  scripts/gdb: Add infrastructure
  scripts/gdb: Add cache for type objects
  scripts/gdb: Add container_of helper and convenience function
  scripts/gdb: Add module iteration helper
  scripts/gdb: Add lx-symbols command
  scripts/gdb: Add internal helper and convenience function to look up
    a module
  scripts/gdb: Add lx_modvar convenience function
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
  scripts/gdb: Add helper to iterate over CPU masks
  scripts/gdb: Add lx-lsmod command
  scripts/gdb: Add basic documentation

 Documentation/gdb-kernel-debugging.txt |  155 +++++++++++++++++++++++++++++++
 Makefile                               |    5 +-
 scripts/Makefile                       |    3 +-
 scripts/gdb/Makefile                   |    9 ++
 scripts/gdb/dmesg.py                   |   63 +++++++++++++
 scripts/gdb/module.py                  |  149 ++++++++++++++++++++++++++++++
 scripts/gdb/percpu.py                  |  110 ++++++++++++++++++++++
 scripts/gdb/symbols.py                 |  147 +++++++++++++++++++++++++++++
 scripts/gdb/task.py                    |   99 ++++++++++++++++++++
 scripts/gdb/utils.py                   |  158 ++++++++++++++++++++++++++++++++
 scripts/gdb/vmlinux-gdb.py             |   29 ++++++
 11 files changed, 925 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/gdb-kernel-debugging.txt
 create mode 100644 scripts/gdb/Makefile
 create mode 100644 scripts/gdb/dmesg.py
 create mode 100644 scripts/gdb/module.py
 create mode 100644 scripts/gdb/percpu.py
 create mode 100644 scripts/gdb/symbols.py
 create mode 100644 scripts/gdb/task.py
 create mode 100644 scripts/gdb/utils.py
 create mode 100644 scripts/gdb/vmlinux-gdb.py

-- 
1.7.3.4

