From: Tiezhu Yang <yangtiezhu@loongson.cn>
Date: Fri, 10 Dec 2021 13:35:59 +0000
Subject: [PATCH 0/2] kdump: simplify code
Message-Id: <1639143361-17773-1-git-send-email-yangtiezhu@loongson.cn>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, x86@kernel.org, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org

Tiezhu Yang (2):
  kdump: vmcore: move copy_to() from vmcore.c to uaccess.h
  kdump: crashdump: use copy_to() to simplify the related code

 arch/arm/kernel/crash_dump.c     | 10 ++--------
 arch/arm64/kernel/crash_dump.c   | 10 ++--------
 arch/ia64/kernel/crash_dump.c    | 10 ++++------
 arch/mips/kernel/crash_dump.c    |  9 ++-------
 arch/powerpc/kernel/crash_dump.c |  7 ++-----
 arch/riscv/kernel/crash_dump.c   |  9 ++-------
 arch/sh/kernel/crash_dump.c      |  9 ++-------
 arch/x86/kernel/crash_dump_32.c  |  9 ++-------
 arch/x86/kernel/crash_dump_64.c  |  9 ++-------
 fs/proc/vmcore.c                 | 14 --------------
 include/linux/uaccess.h          | 14 ++++++++++++++
 11 files changed, 34 insertions(+), 76 deletions(-)

-- 
2.1.0
