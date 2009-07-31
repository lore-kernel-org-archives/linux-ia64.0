From: Tim Abbott <tabbott@ksplice.com>
Date: Fri, 31 Jul 2009 20:57:52 +0000
Subject: [PATCH 2/3] ia64: Use standard macros for page-aligned data.
Message-Id: <1249073873-30028-2-git-send-email-tabbott@ksplice.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1249073873-30028-1-git-send-email-tabbott@ksplice.com>
In-Reply-To: <1249073873-30028-1-git-send-email-tabbott@ksplice.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Anders Kaseorg <andersk@ksplice.com>, Nelson Elhage <nelhage@ksplice.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

From: Nelson Elhage <nelhage@ksplice.com>

Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/head.S        |    2 +-
 arch/ia64/kernel/vmlinux.lds.S |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 8239ff6..ef27e79 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -167,7 +167,7 @@ RestRR:											\
 	mov _tmp2=((ia64_rid(IA64_REGION_ID_KERNEL, (num<<61)) << 8) | (pgsize << 2) | vhpt);; \
 	mov rr[_tmp1]=_tmp2
 
-	.section __special_page_section,"ax"
+	__PAGE_ALIGNED_DATA
 
 	.global empty_zero_page
 empty_zero_page:
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index fa3a558..b484b86 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -219,7 +219,9 @@ SECTIONS
 	{ *(.data.init_task) }
 
   .data.page_aligned : AT(ADDR(.data.page_aligned) - LOAD_OFFSET)
-        { *(__special_page_section)
+        {
+	PAGE_ALIGNED_DATA(PAGE_SIZE)
+	  . = ALIGN(PAGE_SIZE);
 	  __start_gate_section = .;
 	  *(.data.gate)
 	  __stop_gate_section = .;
-- 
1.6.3.3

