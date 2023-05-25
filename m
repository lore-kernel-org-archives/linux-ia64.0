From: Nadav Amit <nadav.amit@gmail.com>
Date: Thu, 25 May 2023 21:00:37 +0000
Subject: [PATCH v2 0/3] kprobes: notrace enhancements
Message-Id: <20230525210040.3637-1-namit@vmware.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Nadav Amit <namit@vmware.com>

From: Nadav Amit <namit@vmware.com>

There are inconsistencies and some issues in marking functions as
notrace. On one hand, all inline functions are marked as "notrace" and
some libraries cannot be traced. As more users and tools try to make use
of the tracing functionality, it is beneficial to allow their tracing as
possible.

At the same time, some functions should not be traced but are not marked
as notrace.

These patch address issues that I encountered during work on an
automatic tracing tool.

---

v1->v2:
* Add find_bit to tracable libraries
* Improve the change log to explain the reasons for inline->notrace
* Switch the order of patch 2 and patch 3


Nadav Amit (3):
  kprobes: Mark descendents of core_kernel_text as notrace
  compiler: inline does not imply notrace
  lib: Allow traceing of usercopy, xarray, iov_iter, find_bit

 arch/arm/kernel/process.c             | 2 +-
 arch/ia64/mm/init.c                   | 2 +-
 arch/x86/entry/vsyscall/vsyscall_64.c | 2 +-
 arch/x86/um/mem_32.c                  | 2 +-
 include/asm-generic/sections.h        | 6 +++---
 include/linux/compiler_types.h        | 2 +-
 include/linux/kallsyms.h              | 6 +++---
 include/linux/mm.h                    | 2 +-
 lib/Makefile                          | 5 +++++
 9 files changed, 17 insertions(+), 12 deletions(-)

-- 
2.25.1
