From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 17:20:27 +0000
Subject: [patch 6/6] move patchlist and machvec into init section
Message-Id: <200603121720.k2CHKPg10336@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64_mv is initialized based on platform detected or specified.
However, there is one instantiation of each platform type.  We
don't expect to switch platform vector during run time.  Move
those platform specific type into init section since a copy is
made into global ia64_mv at initialization.

Also move instruction patch list into init section as well.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/vmlinux.lds.S.orig	2006-03-12 01:48:31.255471910 -0800
+++ ./arch/ia64/kernel/vmlinux.lds.S	2006-03-12 01:53:12.983007521 -0800
@@ -70,34 +70,9 @@ SECTIONS
 	  __stop___ex_table = .;
 	}
 
-  .data.patch.vtop : AT(ADDR(.data.patch.vtop) - LOAD_OFFSET)
-	{
-	  __start___vtop_patchlist = .;
-	  *(.data.patch.vtop)
-	  __end___vtop_patchlist = .;
-	}
-
-  .data.patch.mckinley_e9 : AT(ADDR(.data.patch.mckinley_e9) - LOAD_OFFSET)
-	{
-	  __start___mckinley_e9_bundles = .;
-	  *(.data.patch.mckinley_e9)
-	  __end___mckinley_e9_bundles = .;
-	}
-
   /* Global data */
   _data = .;
 
-#if defined(CONFIG_IA64_GENERIC)
-  /* Machine Vector */
-  . = ALIGN(16);
-  .machvec : AT(ADDR(.machvec) - LOAD_OFFSET)
-	{
-	  machvec_start = .;
-	  *(.machvec)
-	  machvec_end = .;
-	}
-#endif
-
   /* Unwind info & table: */
   . = ALIGN(8);
   .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - LOAD_OFFSET)
@@ -154,6 +129,32 @@ SECTIONS
 	  *(.initcall7.init)
 	  __initcall_end = .;
 	}
+
+  .data.patch.vtop : AT(ADDR(.data.patch.vtop) - LOAD_OFFSET)
+	{
+	  __start___vtop_patchlist = .;
+	  *(.data.patch.vtop)
+	  __end___vtop_patchlist = .;
+	}
+
+  .data.patch.mckinley_e9 : AT(ADDR(.data.patch.mckinley_e9) - LOAD_OFFSET)
+	{
+	  __start___mckinley_e9_bundles = .;
+	  *(.data.patch.mckinley_e9)
+	  __end___mckinley_e9_bundles = .;
+	}
+
+#if defined(CONFIG_IA64_GENERIC)
+  /* Machine Vector */
+  . = ALIGN(16);
+  .machvec : AT(ADDR(.machvec) - LOAD_OFFSET)
+	{
+	  machvec_start = .;
+	  *(.machvec)
+	  machvec_end = .;
+	}
+#endif
+
    __con_initcall_start = .;
   .con_initcall.init : AT(ADDR(.con_initcall.init) - LOAD_OFFSET)
 	{ *(.con_initcall.init) }


