From: Tim Abbott <tabbott@ksplice.com>
Date: Wed, 16 Sep 2009 16:42:43 +0000
Subject: [PATCH v2 2/3] ia64: Use standard macros for page-aligned data.
Message-Id: <1253119364-19359-3-git-send-email-tabbott@ksplice.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253119364-19359-1-git-send-email-tabbott@ksplice.com>
In-Reply-To: <1253119364-19359-1-git-send-email-tabbott@ksplice.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>, Nelson Elhage <nelhage@ksplice.com>

From: Nelson Elhage <nelhage@ksplice.com>

Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/head.S        |    2 +-
 arch/ia64/kernel/vmlinux.lds.S |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 07c7efb..bb248db 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -168,7 +168,7 @@ RestRR:											\
 	mov _tmp2=((ia64_rid(IA64_REGION_ID_KERNEL, (num<<61)) << 8) | (pgsize << 2) | vhpt);; \
 	mov rr[_tmp1]=_tmp2
 
-	.section __special_page_section,"ax"
+	__PAGE_ALIGNED_DATA
 
 	.global empty_zero_page
 empty_zero_page:
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index e7a040e..7976719 100644
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

