From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 15 May 2001 07:36:41 +0000
Subject: [Linux-ia64] libffi patch
Message-Id: <marc-linux-ia64-105590693005574@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a completely unofficial libffi patch.  It is relative to the
libffi that comes with the CVS tree of gcc3.0.  I'm not sure whether
this patch will be acceptable to the libffi maintainer, but for now,
it is what's needed to get mozilla/ia64 working...

	--david

Index: include/ffi.h.in
=================================RCS file: /cvs/gcc/gcc/libffi/include/ffi.h.in,v
retrieving revision 1.7.2.2
diff -u -r1.7.2.2 ffi.h.in
--- include/ffi.h.in	2001/03/27 00:58:23	1.7.2.2
+++ include/ffi.h.in	2001/05/15 06:25:31
@@ -380,6 +380,30 @@
 };
 #define FFI_NATIVE_RAW_API 0
 
+#define FFI_STATIC_CLOSURE(name, cif, interp, user_data)		\
+  __asm__ ("     .data\n"						\
+           "     .align 8\n"						\
+           "1:   data8 @fptr(ffi_closure_UNIX)\n"			\
+           "     data8 1b\n"						\
+	   "     data8 0\n"						\
+           "     data8 "#cif"\n"					\
+           "     data8 @fptr("#interp")\n"				\
+           "     data8 "#user_data"\n"					\
+           "     .text\n"						\
+           "     .global "#name"\n"					\
+           "     .proc "#name"\n"					\
+           #name":\n"							\
+           "     addl r16 = @ltoff(1b), gp;;\n"				\
+           "     ld8  gp = [r16];;\n"    /* fake gp = &closure */	\
+           "     ld8  r17 = [gp];;\n"    /* r17 = @fptr(...) */		\
+	   "     ld8  r19 = [r17],8;\n"  /* r19 = code addr */		\
+	   "	 adds r18 = 16,gp;;\n"					\
+	   "     ld8  r20 = [r17];;\n"	 /* r20 = real gp */		\
+	   "     st8  [r18]=r20;\n"					\
+           "     mov b6 = r19\n"					\
+           "     br.cond.sptk.many b6\n"				\
+           "     .endp\n");
+
 #elif defined(ALPHA)
 
 #define FFI_CLOSURES 1
@@ -406,15 +430,17 @@
 typedef struct {
   char tramp[FFI_TRAMPOLINE_SIZE];
   ffi_cif   *cif;
-  void     (*fun)(ffi_cif*,void*,void**,void*);
+  void     (*fun)(ffi_cif*,void*,void**,void*,void*);
   void      *user_data;
 } ffi_closure;
 
 ffi_status
 ffi_prep_closure (ffi_closure*,
 		  ffi_cif *,
-		  void (*fun)(ffi_cif*,void*,void**,void*),
+		  void (*fun)(ffi_cif*,void*,void**,void*,void*),
 		  void *user_data);
+
+extern void ffi_prep_incoming_args (ffi_cif *, void *, void **);
 
 #if !FFI_NO_RAW_API
 
Index: src/ia64/ffi.c
=================================RCS file: /cvs/gcc/gcc/libffi/src/ia64/ffi.c,v
retrieving revision 1.1
diff -u -r1.1 ffi.c
--- src/ia64/ffi.c	2000/02/25 19:13:44	1.1
+++ src/ia64/ffi.c	2001/05/15 06:25:31
@@ -497,7 +499,7 @@
 
   ffi_prep_incoming_args_UNIX(args, (void**)&resp, arg_area, cif);
   
-  (closure->fun) (cif, resp, arg_area, closure->user_data);
+  (closure->fun) (cif, resp, arg_area, closure->user_data, args);
 
   rtype = cif->flags;
 
@@ -633,6 +636,13 @@
   return;
 }
 
+void
+ffi_prep_incoming_args (ffi_cif *cif, void *raw_args, void **args)
+{
+    void *dummy_resp;
+
+    ffi_prep_incoming_args_UNIX(raw_args, &dummy_resp, args, cif);
+}
 
 /* Fill in a closure to refer to the specified fun and user_data.	*/
 /* cif specifies the argument and result types for fun.			*/
@@ -648,7 +658,7 @@
 ffi_status
 ffi_prep_closure (ffi_closure* closure,
 		  ffi_cif* cif,
-		  void (*fun)(ffi_cif*,void*,void**,void*),
+		  void (*fun)(ffi_cif*,void*,void**,void*,void*),
 		  void *user_data)
 {
   struct ffi_ia64_trampoline_struct *tramp 

