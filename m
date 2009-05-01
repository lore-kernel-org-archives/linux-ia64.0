From: Tim Abbott <tabbott@MIT.EDU>
Date: Fri, 01 May 2009 00:04:06 +0000
Subject: [PATCH 4/5] ia64: use new macro for .data.read_mostly section.
Message-Id: <1241136247-10623-5-git-send-email-tabbott@mit.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1241136247-10623-1-git-send-email-tabbott@mit.edu>
 <1241136247-10623-2-git-send-email-tabbott@mit.edu>
 <1241136247-10623-3-git-send-email-tabbott@mit.edu>
 <1241136247-10623-4-git-send-email-tabbott@mit.edu>
In-Reply-To: <1241136247-10623-4-git-send-email-tabbott@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>, Anders Kaseorg <andersk@MIT.EDU>, Waseem Daher <wdaher@MIT.EDU>, Denys Vlasenko <vda.linux@googlemail.com>, Jeff Arnold <jbarnold@MIT.EDU>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Tim Abbott <tabbott@MIT.EDU>

As with .data.cacheline_aligned, I eliminated the separate output
section and set the alignment to SMP_CACHE_BYTES.  An ack from Tony
would be appreciated.

Signed-off-by: Tim Abbott <tabbott@mit.edu>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/vmlinux.lds.S |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 9c4cc29..e99faad 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -230,9 +230,6 @@ SECTIONS
   				 * kernel data
 				 */
 
-  .data.read_mostly : AT(ADDR(.data.read_mostly) - LOAD_OFFSET)
-        { *(.data.read_mostly) }
-
   /* Per-cpu data: */
   . = ALIGN(PERCPU_PAGE_SIZE);
   PERCPU_VADDR(PERCPU_ADDR, :percpu)
@@ -251,6 +248,7 @@ SECTIONS
 #endif
 		INIT_TASK_DATA(PAGE_SIZE)
 		CACHELINE_ALIGNED_DATA(SMP_CACHE_BYTES)
+		READ_MOSTLY_DATA(SMP_CACHE_BYTES)
 		DATA_DATA
 		*(.data1)
 		*(.gnu.linkonce.d*)
-- 
1.6.2.1

