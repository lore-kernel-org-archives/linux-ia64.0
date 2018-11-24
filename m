From: Lianbo Jiang <lijiang@redhat.com>
Date: Sat, 24 Nov 2018 05:12:21 +0000
Subject: [PATCH 0/2 RESEND v7] add reserved e820 ranges to the kdump kernel e820 table
Message-Id: <20181124051223.19994-1-lijiang@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, dyoung@redhat.com, bhe@redhat.com

These patches add the new I/O resource descriptor 'IORES_DESC_RESERVED'
for the iomem resources search interfaces, and in order to make it still
work after the new descriptor is added, these codes originally related
to 'IORES_DESC_NONE' have been updated.

In addition, for the MMCONFIG issue and the SME kdump issue, it is
necessary to pass the e820 reserved ranges to kdump kernel.

Changes since v1:
1. Modified the value of flags to "0", when walking through the whole
tree for e820 reserved ranges.

Changes since v2:
1. Modified the value of flags to "0", when walking through the whole
tree for e820 reserved ranges.
2. Modified the invalid SOB chain issue.

Changes since v3:
1. Dropped [PATCH 1/3 v3] resource: fix an error which walks through iomem
   resources. Please refer to this commit <010a93bf97c7> "resource: Fix
   find_next_iomem_res() iteration issue"

Changes since v4:
1. Improve the patch log, and add kernel log.

Changes since v5:
1. Rewrite these patches log.

Changes since v6:
1. Modify the [PATCH 1/2], and add the new I/O resource descriptor
   'IORES_DESC_RESERVED' for the iomem resources search interfaces,
   and also updates these codes relates to 'IORES_DESC_NONE'.
2. Modify the [PATCH 2/2], and walk through io resource based on the
   new descriptor 'IORES_DESC_RESERVED'.
3. Update patch log.

Lianbo Jiang (2):
  resource: add the new I/O resource descriptor 'IORES_DESC_RESERVED'
  x86/kexec_file: add reserved e820 ranges to kdump kernel e820 table

 arch/ia64/kernel/efi.c  | 4 ++++
 arch/x86/kernel/crash.c | 6 ++++++
 arch/x86/kernel/e820.c  | 2 +-
 arch/x86/mm/ioremap.c   | 9 ++++++++-
 include/linux/ioport.h  | 1 +
 kernel/resource.c       | 6 +++---
 6 files changed, 23 insertions(+), 5 deletions(-)

-- 
2.17.1
