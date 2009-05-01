From: Tim Abbott <tabbott@MIT.EDU>
Date: Fri, 01 May 2009 00:04:04 +0000
Subject: [PATCH 2/5] ia64: use new macro for .data.cacheline_aligned section.
Message-Id: <1241136247-10623-3-git-send-email-tabbott@mit.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1241136247-10623-1-git-send-email-tabbott@mit.edu>
 <1241136247-10623-2-git-send-email-tabbott@mit.edu>
In-Reply-To: <1241136247-10623-2-git-send-email-tabbott@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>, Anders Kaseorg <andersk@MIT.EDU>, Waseem Daher <wdaher@MIT.EDU>, Denys Vlasenko <vda.linux@googlemail.com>, Jeff Arnold <jbarnold@MIT.EDU>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Tim Abbott <tabbott@MIT.EDU>

.data.cacheline_aligned should not need a separate output section;
this change moves it into the .data section.

Signed-off-by: Tim Abbott <tabbott@mit.edu>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/vmlinux.lds.S |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index fa3a558..cdcd655 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -237,9 +237,6 @@ SECTIONS
   .data.read_mostly : AT(ADDR(.data.read_mostly) - LOAD_OFFSET)
         { *(.data.read_mostly) }
 
-  .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - LOAD_OFFSET)
-        { *(.data.cacheline_aligned) }
-
   /* Per-cpu data: */
   . = ALIGN(PERCPU_PAGE_SIZE);
   PERCPU_VADDR(PERCPU_ADDR, :percpu)
@@ -256,6 +253,7 @@ SECTIONS
 		__cpu0_per_cpu = .;
   . = . + PERCPU_PAGE_SIZE;	/* cpu0 per-cpu space */
 #endif
+		CACHELINE_ALIGNED_DATA(SMP_CACHE_BYTES)
 		DATA_DATA
 		*(.data1)
 		*(.gnu.linkonce.d*)
-- 
1.6.2.1

