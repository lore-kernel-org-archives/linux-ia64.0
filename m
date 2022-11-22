From: Nadav Amit <nadav.amit@gmail.com>
Date: Tue, 22 Nov 2022 19:53:26 +0000
Subject: [PATCH 0/3] kprobes: notrace enhancements
Message-Id: <20221122195329.252654-1-namit@vmware.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Nadav Amit <namit@vmware.com>

From: Nadav Amit <namit@vmware.com>

There are inconsistencies and some issues in marking functions as
notrace. On one hand, all inline functions are marked as "notrace" and
some libraries cannot be traced. At the same time, some functions should
not be traced but are not marked as notrace.

These patch address issues that I encountered during work on an
automatic tracing tool.

Nadav Amit (3):
  kprobes: Mark descendents of core_kernel_text as notrace
  lib/usercopy: Allow traceing of usercopy, xarray, iov_iter
  compiler: inline does not imply notrace

 arch/arm/kernel/process.c             | 2 +-
 arch/ia64/mm/init.c                   | 2 +-
 arch/x86/entry/vsyscall/vsyscall_64.c | 2 +-
 arch/x86/um/mem_32.c                  | 2 +-
 include/asm-generic/sections.h        | 6 +++---
 include/linux/compiler_types.h        | 2 +-
 include/linux/kallsyms.h              | 6 +++---
 include/linux/mm.h                    | 2 +-
 lib/Makefile                          | 3 +++
 9 files changed, 15 insertions(+), 12 deletions(-)

-- 
2.25.1
