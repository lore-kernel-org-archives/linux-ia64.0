From: Roland McGrath <roland@redhat.com>
Date: Thu, 18 Oct 2007 19:54:53 +0000
Subject: [PATCH] ia64: check-segrel.lds vs --build-id
Message-Id: <20071018195453.A34D64D04E2@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Doug Chapman <dchapman@redhat.com>

Some versions of ld with --build-id support will crash when using the flag
with a linker script that discards notes.  This bites ia64's check-segrel.lds.
The bug is easy to avoid.

Signed-off-by: Roland McGrath <roland@redhat.com>

--- a/arch/ia64/scripts/check-segrel.lds
+++ b/arch/ia64/scripts/check-segrel.lds
@@ -1,6 +1,7 @@
 SECTIONS {
 	. = SIZEOF_HEADERS;
 	.rodata : { *(.rodata) } :ro
+	.note : { *(.note*) }
 	. = 0xa0000;
 	.data : { *(.data) } :dat
 	/DISCARD/ : { *(*) }

