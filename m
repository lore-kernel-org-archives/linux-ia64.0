From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 22 Apr 2008 06:42:18 +0000
Subject: [PATCH 0/3] ia64/pv_ops preparation
Message-Id: <12088465413472-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi. This patchset is preparation patches for ia64/pv_ops support.
They are almost trivial and mainly make kernel paravirtualization friendly.

thanks,

Diffstat:
 arch/ia64/kernel/irq_ia64.c    |    1 -
 include/asm-ia64/intrinsics.h  |   11 +++++++++++
 include/asm-ia64/mmu_context.h |    6 +-----
 include/asm-ia64/smp.h         |    2 ++
 include/asm-ia64/system.h      |   10 ++++++++--
 5 files changed, 22 insertions(+), 8 deletions(-)
