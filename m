From: Al Stone <ahs3@fc.hp.com>
Date: Sat, 12 Aug 2006 17:08:12 +0000
Subject: [PATCH] minor reformatting to vmlinux.lds.S
Message-Id: <1155402492.2009.17.camel@deimos>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Minor reformatting to vmlinux.lds.S to make it 80-column usable,
in accordance with Linux coding style.


Signed-off-by: Al Stone <ahs3@fc.hp.com>


diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 5b0d5f6..b3b2e38 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -184,7 +184,9 @@ #endif
 	  *(.data.gate)
 	  __stop_gate_section = .;
 	}
-  . = ALIGN(PAGE_SIZE);		/* make sure the gate page doesn't expose kernel data */
+  . = ALIGN(PAGE_SIZE);		/* make sure the gate page doesn't expose
+  				 * kernel data
+				 */
 
   .data.read_mostly : AT(ADDR(.data.read_mostly) - LOAD_OFFSET)
         { *(.data.read_mostly) }
@@ -202,7 +204,9 @@ #endif
 		*(.data.percpu)
 		__per_cpu_end = .;
 	}
-  . = __phys_per_cpu_start + PERCPU_PAGE_SIZE;	/* ensure percpu data fits into percpu page size */
+  . = __phys_per_cpu_start + PERCPU_PAGE_SIZE;	/* ensure percpu data fits
+  						 * into percpu page size
+						 */
 
   data : { } :data
   .data : AT(ADDR(.data) - LOAD_OFFSET)



-- 
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
Open Source and Linux R&D                     Debian Developer
Hewlett-Packard Company                       http://www.debian.org
E-mail: ahs3@fc.hp.com                        ahs3@debian.org
----------------------------------------------------------------------

