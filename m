From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 12 Oct 2006 19:18:13 +0000
Subject: [PATCH 1/4] Fix alignment of __condata_*
Message-Id: <20061012191813.21498.394.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix alignment for CONFIG_IA64_SGI

The _con.... variables happened to be placed on a 4 byte
boundary in some compiles for CONFIG_IA64_SGI. Wasted some time
chasing ghosts in functions that were never executed but modifications
to these function would oops the system. Make sure that
this does not happen again.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/kernel/vmlinux.lds.S	2006-10-04 21:57:05.000000000 -0500
+++ linux-2.6.19-rc1-mm1/arch/ia64/kernel/vmlinux.lds.S	2006-10-10 21:45:30.768864235 -0500
@@ -163,6 +163,7 @@ SECTIONS
 	}
 #endif
 
+  . = ALIGN(16);
    __con_initcall_start = .;
   .con_initcall.init : AT(ADDR(.con_initcall.init) - LOAD_OFFSET)
 	{ *(.con_initcall.init) }
