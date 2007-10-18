From: Roland McGrath <roland@redhat.com>
Date: Thu, 18 Oct 2007 22:11:08 +0000
Subject: [PATCH] ia64 vDSO vs --build-id
Message-Id: <20071018221108.638644D04E2@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, Doug Chapman <dchapman@redhat.com>

When gcc uses --build-id by default, the gate.lds.S linker script runs afoul
of the new note section and produces a bad DSO image.  This fixes it.

Signed-off-by: Roland McGrath <roland@redhat.com>

--- a/arch/ia64/kernel/gate.lds.S
+++ b/arch/ia64/kernel/gate.lds.S
@@ -20,6 +20,8 @@ SECTIONS
 	.gnu.version_d		: { *(.gnu.version_d) }
 	.gnu.version_r		: { *(.gnu.version_r) }
 
+	.note			: { *(.note*) }		:readable	:note
+
 	.dynamic		: { *(.dynamic) }	:readable	:dynamic
 
 	/*
@@ -83,6 +85,7 @@ PHDRS
 	epc		PT_LOAD	FILEHDR PHDRS	FLAGS(1);	/* PF_X */
 #endif
 	dynamic		PT_DYNAMIC		FLAGS(4);	/* PF_R */
+	note		PT_NOTE			FLAGS(4);	/* PF_R */
 	unwind		PT_IA_64_UNWIND;
 }
 
