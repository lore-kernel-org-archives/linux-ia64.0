From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:12 +0000
Subject: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

	Hello,

	A rather automatic replacement of print_symbol()
with direct printk() calls. print_symbol() uses extra stack
buffer (KSYM_SYMBOL_LEN 128 bytes) and, basically, should
be identical to printk(%pS).

	I can't test all of the patches, because I don't
own any of those exotic arch-s. Sorry for the inconvenience.

Sergey Senozhatsky (13):
  arm: do not use print_symbol()
  arm64: do not use print_symbol()
  c6x: do not use print_symbol()
  ia64: do not use print_symbol()
  mn10300: do not use print_symbol()
  sh: do not use print_symbol()
  unicore32: do not use print_symbol()
  x86: do not use print_symbol()
  drivers: do not use print_symbol()
  sysfs: do not use print_symbol()
  irq debug: do not use print_symbol()
  lib: do not use print_symbol()
  arc: do not use __print_symbol()

 arch/arc/kernel/stacktrace.c     |  2 +-
 arch/arm/kernel/process.c        |  5 ++---
 arch/arm64/kernel/process.c      |  5 ++---
 arch/c6x/kernel/traps.c          |  4 +---
 arch/ia64/kernel/process.c       | 10 +++-------
 arch/mn10300/kernel/traps.c      |  4 +---
 arch/sh/kernel/process_32.c      |  5 ++---
 arch/unicore32/kernel/process.c  |  5 ++---
 arch/x86/kernel/cpu/mcheck/mce.c |  3 +--
 arch/x86/mm/mmio-mod.c           |  5 ++---
 drivers/base/core.c              |  5 ++---
 fs/sysfs/file.c                  |  5 ++---
 kernel/irq/debug.h               |  8 +++-----
 lib/smp_processor_id.c           |  3 +--
 14 files changed, 25 insertions(+), 44 deletions(-)

-- 
2.15.1

