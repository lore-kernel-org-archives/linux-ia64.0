From: Tiezhu Yang <yangtiezhu@loongson.cn>
Date: Sat, 11 Dec 2021 03:33:06 +0000
Subject: [PATCH v2 0/2] kdump: simplify code
Message-Id: <1639193588-7027-1-git-send-email-yangtiezhu@loongson.cn>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, x86@kernel.org, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Xuefeng Li <lixuefeng@loongson.cn>

v2:
  -- add copy_to_user_or_kernel() in lib/usercopy.c
  -- define userbuf as bool type

Tiezhu Yang (2):
  kdump: vmcore: remove copy_to() and add copy_to_user_or_kernel()
  kdump: crashdump: use copy_to_user_or_kernel() to simplify code

 arch/arm/kernel/crash_dump.c     | 12 +++---------
 arch/arm64/kernel/crash_dump.c   | 12 +++---------
 arch/ia64/kernel/crash_dump.c    | 12 +++++-------
 arch/mips/kernel/crash_dump.c    | 11 +++--------
 arch/powerpc/kernel/crash_dump.c | 11 ++++-------
 arch/riscv/kernel/crash_dump.c   | 11 +++--------
 arch/sh/kernel/crash_dump.c      | 11 +++--------
 arch/x86/kernel/crash_dump_32.c  | 11 +++--------
 arch/x86/kernel/crash_dump_64.c  | 15 +++++----------
 fs/proc/vmcore.c                 | 32 +++++++++-----------------------
 include/linux/crash_dump.h       |  8 ++++----
 include/linux/uaccess.h          |  1 +
 lib/usercopy.c                   | 15 +++++++++++++++
 13 files changed, 61 insertions(+), 101 deletions(-)

-- 
2.1.0
