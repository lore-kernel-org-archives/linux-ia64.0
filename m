From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 15 May 2001 07:34:13 +0000
Subject: [Linux-ia64] mozilla/ia64 patch
Message-Id: <marc-linux-ia64-105590693005573@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a patch that makes mozilla work on IA-64 (native, not via
IA-32 emulation).  The patch is relative to a recent snapshot of the
CVS tree (I think I took the snapshot on May 12th).  The first part is
stuff that Jim Nance and a couple of mozilla developers contributed a
while ago.  The new code consists of the two files at the end of the
patch: xptcinvoke_ffi.cpp and xptcstubs_ffi.cpp.  These files
implement the mozilla xptcall facility using a (slightly enhanced)
version of libffi ("foreign function interface").  The nice thing
about using libffi is that the resulting mozilla files are
platform-independent with two minor exceptions: layout of the vtable
and the C++ name mangling.  Even so, the current libffi based
implementation *should* work both on IA-64 and Alpha, as far as I can
tell (the latter has not been tested though).

With the patch below applied and a libffi patch that I'll mail out
separately, you should be able to build a working mozilla/ia64 binary.
I used the g++ compiler as included in the latest Red Hat beta
("wolverine").  Originally, I tried the g++ in the gcc3.0 CVS tree,
but that didn't get me very far: g++ 3.0 seems more picky about static
casts between pointers and 32-bit ints and there was also an
internal-compiler-error on one file (I reported the problem to Jim
Wilson).

My build had debugging enabled and optimization turned off.  I have no
reason to believe that it won't work with debugging turned off, but I
haven't tried that (actually, I don't know how to build an optimized
version... ;-).  Testing has not been extensive.  The TestXPTCInvoke
test suite completes successfully, but this doesn't test the "stubs"
facility of xptcall at all.  Visiting various web sites (some with
JavaScript) seemed to work fine, so I'll assume that the "stubs"
facility works at least to some degree.  Even the mail/news reader,
document editor, and the address book seem to work fine (though I
rarely use these, so I'm not exactly a power user...).

I don't expect to have much more time to play/debug mozilla/ia64, but
I hope the attached patch is good enough to get others started.  Also,
if there are any questions/problems regarding the ffi based
implementation of xptcall, I'd be happy to try to help.  Note: one
thing I'm sure needs fixing is the Makefile in xpcom/build (look for
"fix me" in the patch below).  I'm not familiar with the Mozilla build
process and therefore did just the quick and dirty thing to always
link in libffi.  Obviously, this should be done only on those
platforms that use this implementation.

Enjoy,

	--david

Index: nsprpub/pr/include/md/_linux.cfg
=================================RCS file: /cvsroot/mozilla/nsprpub/pr/include/md/_linux.cfg,v
retrieving revision 3.8.2.1
diff -u -r3.8.2.1 _linux.cfg
--- nsprpub/pr/include/md/nsprpub/pr/include/md/_linux.cfg	2000/07/29 01:01:57	3.8.2.1
+++ nsprpub/pr/include/md/nsprpub/pr/include/md/_linux.cfg	2001/05/15 06:26:04
@@ -120,6 +120,52 @@
 #define PR_BYTES_PER_WORD_LOG2  3
 #define PR_BYTES_PER_DWORD_LOG2 3
 
+#elif defined(__ia64__)
+
+#define IS_LITTLE_ENDIAN 1
+#undef  IS_BIG_ENDIAN
+#define IS_64
+
+#define PR_BYTES_PER_BYTE   1
+#define PR_BYTES_PER_SHORT  2
+#define PR_BYTES_PER_INT    4
+#define PR_BYTES_PER_INT64  8
+#define PR_BYTES_PER_LONG   8
+#define PR_BYTES_PER_FLOAT  4
+#define PR_BYTES_PER_DOUBLE 8
+#define PR_BYTES_PER_WORD   8
+#define PR_BYTES_PER_DWORD  8
+
+#define PR_BITS_PER_BYTE    8
+#define PR_BITS_PER_SHORT   16
+#define PR_BITS_PER_INT     32
+#define PR_BITS_PER_INT64   64
+#define PR_BITS_PER_LONG    64
+#define PR_BITS_PER_FLOAT   32
+#define PR_BITS_PER_DOUBLE  64
+#define PR_BITS_PER_WORD    64
+
+#define PR_BITS_PER_BYTE_LOG2   3
+#define PR_BITS_PER_SHORT_LOG2  4
+#define PR_BITS_PER_INT_LOG2    5
+#define PR_BITS_PER_INT64_LOG2  6
+#define PR_BITS_PER_LONG_LOG2   6
+#define PR_BITS_PER_FLOAT_LOG2  5
+#define PR_BITS_PER_DOUBLE_LOG2 6
+#define PR_BITS_PER_WORD_LOG2   6
+
+#define PR_ALIGN_OF_SHORT   2
+#define PR_ALIGN_OF_INT     4
+#define PR_ALIGN_OF_LONG    8
+#define PR_ALIGN_OF_INT64   8
+#define PR_ALIGN_OF_FLOAT   4
+#define PR_ALIGN_OF_DOUBLE  8
+#define PR_ALIGN_OF_POINTER 8
+#define PR_ALIGN_OF_WORD    8
+
+#define PR_BYTES_PER_WORD_LOG2  3
+#define PR_BYTES_PER_DWORD_LOG2 3
+
 #elif defined(__mc68000__)
 
 #undef  IS_LITTLE_ENDIAN
Index: nsprpub/pr/include/md/_linux.h
=================================RCS file: /cvsroot/mozilla/nsprpub/pr/include/md/_linux.h,v
retrieving revision 3.24.2.2
diff -u -r3.24.2.2 _linux.h
--- nsprpub/pr/include/md/nsprpub/pr/include/md/_linux.h	2000/05/02 01:47:17	3.24.2.2
+++ nsprpub/pr/include/md/nsprpub/pr/include/md/_linux.h	2001/05/15 06:26:04
@@ -31,6 +31,8 @@
 #define _PR_SI_ARCHITECTURE "ppc"
 #elif defined(__alpha)
 #define _PR_SI_ARCHITECTURE "alpha"
+#elif defined(__ia64__)
+#define _PR_SI_ARCHITECTURE "ia64"
 #elif defined(__mc68000__)
 #define _PR_SI_ARCHITECTURE "m68k"
 #elif defined(__sparc__)
@@ -78,7 +80,7 @@
 #endif
 #undef _PR_USE_POLL
 #define _PR_STAT_HAS_ONLY_ST_ATIME
-#if defined(__alpha)
+#if defined(__alpha) || defined(__ia64__)
 #define _PR_HAVE_LARGE_OFF_T
 #else
 #define _PR_NO_LARGE_FILES
@@ -141,6 +143,16 @@
 
 /* XXX not sure if this is correct, or maybe it should be 17? */
 #define PR_NUM_GCREGS 9
+
+#elif defined(__ia64)
+
+#define _MD_GET_SP(_t)		((long *)((_t)->md.context[0].__jmpbuf)[0])
+#define _MD_SET_FP(_t, val)
+#define _MD_GET_SP_PTR(_t)	&(_MD_GET_SP(_t))
+#define _MD_GET_FP_PTR(_t)	((void *) 0)
+#define _MD_SP_TYPE			long int
+
+#define PR_NUM_GCREGS		_JBLEN
 
 #elif defined(__mc68000__)
 /* m68k based Linux */
Index: xpcom/build/Makefile.in
=================================RCS file: /cvsroot/mozilla/xpcom/build/Makefile.in,v
retrieving revision 1.27
diff -u -r1.27 Makefile.in
--- xpcom/build/xpcom/build/Makefile.in	2001/04/28 19:45:51	1.27
+++ xpcom/build/xpcom/build/Makefile.in	2001/05/15 06:26:06
@@ -63,6 +63,8 @@
 		-I$(srcdir)/../proxy/src \
 		$(NULL)
 
+EXTRA_DSO_LDOPTS += -lffi	# XXX fix me
+
 ifdef MOZ_DEMANGLE_SYMBOLS
 EXTRA_DSO_LDOPTS += -liberty
 endif
--- xpcom/reflect/xptcall/src/md/unix/xptcinvoke_ffi.cpp	Mon May 14 18:03:08 2001
+++ xpcom/reflect/xptcall/src/md/unix/xptcstubs_ffi.cpp	Mon May 14 22:50:58 2001
@@ -23,7 +23,9 @@
  * Contributor(s):
  */
 
-/* Platform specific code to invoke XPCOM methods on native objects */
+/* Implement shared vtbl methods.  This implementation should be
+   completely portable except for the mangled name of the stub
+   routines.  */
 
 /* contributed by David Mosberger <davidm@hpl.hp.com> */
 
@@ -32,74 +34,140 @@
 
 #include "xptcprivate.h"
 
+#define MANGLED_STUB_NAME(n)	Stub##n##__14nsXPTCStubBase
+
+static ffi_type *stub_common_arg_types[1] = { &ffi_type_pointer };
+static ffi_cif stub_common_cif;
+
 static void
-convert_args (PRUint32 n, nsXPTCVariant *params,
-              ffi_type **arg_types, void **args)
+get_incoming_args (PRUint32 n, void *raw_args, const nsXPTMethodInfo* info,
+                   nsXPTCMiniVariant *p)
 {
-    ffi_type *t;
-    PRUint64 i;
-    void *v;
-#   define CVT(nst,ffit,field)						\
-	case nsXPTType::nst:						\
-		t = &ffit; v = &params[i].val.field; break;
+    ffi_type **arg_types, *t;
+    ffi_status status;
+    ffi_cif cif;
+    void **args;
+    PRUintn i;
 
+    /* create the cif (could be cached): */
+    arg_types = (ffi_type **) alloca ((n + 1) * sizeof (arg_types[0]));
+    arg_types[0] = &ffi_type_pointer;	/* implicit "this" argument */
     for (i = 0; i < n; ++i) {
-        if (params[i].IsPtrData()) {
-            arg_types[i] = &ffi_type_pointer;
-            args[i] = &params[i].ptr;
+        const nsXPTParamInfo& param = info->GetParam(i);
+        const nsXPTType& type = param.GetType();
+
+        if (param.IsOut() || !type.IsArithmetic()) {
+            arg_types[i + 1] = &ffi_type_pointer;
             continue;
         }
-        switch (params[i].type) {
-            CVT(T_I8,		ffi_type_sint8,  i8);
-            CVT(T_I16,		ffi_type_sint16, i16);
-            CVT(T_I32,		ffi_type_sint32, i32);
-            CVT(T_I64,		ffi_type_sint64, i64);
-            CVT(T_U8,		ffi_type_uint8,  u8);
-            CVT(T_U16,		ffi_type_uint16, u16);
-            CVT(T_U32,		ffi_type_uint32, u32);
-            CVT(T_U64,		ffi_type_uint64, u64);
-            CVT(T_FLOAT,	ffi_type_float,  f);
-            CVT(T_DOUBLE,	ffi_type_double, u64);
-            CVT(T_BOOL,		ffi_type_sint32, b);
-            CVT(T_CHAR,		ffi_type_schar,  c);
-            CVT(T_WCHAR,	ffi_type_uint32, wc);
-            default:
-              // all the others are plain pointer types
-              t = &ffi_type_pointer;
-              v = &params[i].val.p;
-              break;
+        switch (type) {
+              case nsXPTType::T_I8 :	t = &ffi_type_sint8;  break;
+              case nsXPTType::T_I16:	t = &ffi_type_sint16; break;
+              case nsXPTType::T_I32:	t = &ffi_type_sint32; break;
+              case nsXPTType::T_I64:	t = &ffi_type_sint64; break;
+              case nsXPTType::T_U8 :	t = &ffi_type_uint8;  break;
+              case nsXPTType::T_U16:	t = &ffi_type_uint16; break;
+              case nsXPTType::T_U32:	t = &ffi_type_uint32; break;
+              case nsXPTType::T_U64:	t = &ffi_type_uint64; break;
+              case nsXPTType::T_FLOAT:	t = &ffi_type_float;  break;
+              case nsXPTType::T_DOUBLE:	t = &ffi_type_double; break;
+              case nsXPTType::T_BOOL:	t = &ffi_type_sint32; break;
+              case nsXPTType::T_CHAR:	t = &ffi_type_schar;  break;
+              case nsXPTType::T_WCHAR:	t = &ffi_type_uint32; break;
+
+              default:
+                NS_ASSERTION(0, "bad type");
+                break;
+        }
+        arg_types[i + 1] = t;
+    }
+    status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, n + 1, &ffi_type_uint32,
+                          arg_types);
+    NS_ASSERTION(status = FFI_OK, "status = FFI_OK");
+
+    /* extract the arguments: */
+    args = (void **) alloca((n + 1) * sizeof (args[0]));
+    ffi_prep_incoming_args(&cif, raw_args, args);
+
+    /* fill in the parameter vector: */
+
+    for (i = 0; i < n; ++i) {
+#       define CVT(nst,field,type)                                           \
+	  case FFI_TYPE_##nst: p[i].val.field = *(type *) args[i + 1]; break;
+        switch (arg_types[i + 1]->type) {
+          CVT(SINT8,   i8,  PRInt8);
+          CVT(SINT16,  i16, PRInt16);
+          CVT(SINT32,  i32, PRInt32);
+          CVT(SINT64,  i64, PRInt64);
+          CVT(UINT8,   u8,  PRUint8);
+          CVT(UINT16,  u16, PRUint16);
+          CVT(UINT32,  u32, PRUint32);
+          CVT(UINT64,  u64, PRUint64);
+          CVT(FLOAT,   u32, PRUint32);
+          CVT(DOUBLE,  u64, PRUint64);
+          CVT(POINTER, p,   void *);
+        default:
+          NS_ASSERTION(0, "unexpected ffi type");
+          break;
         }
-        arg_types[i] = t;
-        args[i] = v;
     }
 }
 
-XPTC_PUBLIC_API(nsresult)
-XPTC_InvokeByIndex(nsISupports* that, PRUint32 methodIndex,
-                   PRUint32 paramCount, nsXPTCVariant* params)
+static void xptc_dispatch (ffi_cif *, void *, void **, void *, void *)
+     __asm__("xptc_dispatch") __attribute__((unused));
+
+static void
+xptc_dispatch (ffi_cif *common_cif, void *retp, void **common_args,
+               void *user_data, void *raw_args)
 {
-    struct vtable {
-        long offset;		/* offset to beginning of object */
-        unsigned long rtti;	/* address of run-time type info */
-        void (*methods[1]) ();	/* method table (variable length) */
-    } *vtable = *(struct vtable **) that;
-    ffi_type **arg_types;
-    void **args;
-    ffi_status status;
-    ffi_cif cif;
-    nsresult result;
+    uint32 method_index = (long) user_data;
+    nsIInterfaceInfo* iface_info = NULL;
+    const nsXPTMethodInfo* info;
+    nsXPTCMiniVariant *params;
+    nsXPTCStubBase *self;
+    PRUint8 param_count;
+
+    self = *(nsXPTCStubBase **) common_args[0];
+
+    NS_ASSERTION(self, "no self");
+
+    self->GetInterfaceInfo (&iface_info);
+    NS_ASSERTION(iface_info,"no interface info");
+
+    iface_info->GetMethodInfo (PRUint16(method_index), &info);
+    NS_ASSERTION(info,"no interface info");
 
-    arg_types = (ffi_type **) alloca((paramCount + 1) * sizeof (arg_types[0]));
-    args = (void **) alloca((paramCount + 1) * sizeof (args[0]));
+    param_count = info->GetParamCount ();
+    params = (nsXPTCMiniVariant *) alloca (param_count * sizeof (params[0]));
+    get_incoming_args (param_count, raw_args, info, params);
 
-    arg_types[0] = &ffi_type_pointer;
-    args[0] = &that;
-    convert_args(paramCount, params, arg_types + 1, args + 1);
-    status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, paramCount + 1,
-                          &ffi_type_uint32, arg_types);
-    if (status != FFI_OK)
-        return NS_ERROR_INVALID_ARG;
+    *(nsresult *) retp = self->CallMethod ((PRUint16)method_index, info,
+                                           params);
 
-    ffi_call (&cif, vtable->methods[methodIndex], &result, args);
-    return result;
+    NS_RELEASE(iface_info);
 }
+
+static class init {
+  public:
+    init (void) {
+        ffi_prep_cif(&stub_common_cif, FFI_DEFAULT_ABI, 1, &ffi_type_pointer,
+                     stub_common_arg_types);
+    }
+} initializer;
+
+#define _STUB(name,arg)                                         \
+  FFI_STATIC_CLOSURE(name, stub_common_cif, xptc_dispatch, arg);
+
+/*
+ * nsresult nsXPTCStubBase::Stub##n()
+ */
+#define STUB_ENTRY(n)	_STUB(MANGLED_STUB_NAME(n), n)
+
+#define SENTINEL_ENTRY(n)                               \
+nsresult nsXPTCStubBase::Sentinel##n()                  \
+{                                                       \
+    NS_ASSERTION(0,"nsXPTCStubBase::Sentinel called");  \
+    return NS_ERROR_NOT_IMPLEMENTED;                    \
+}
+
+#include "xptcstubsdef.inc"
--- /dev/null	Sat Mar 24 01:35:12 2001
+++ xpcom/reflect/xptcall/src/md/unix/xptcinvoke_ffi.cpp	Mon May 14 18:03:08 2001
@@ -0,0 +1,105 @@
+/* -*- Mode: C; tab-width: 8; indent-tabs-mode: nil; c-basic-offset: 4 -*-
+ *
+ * The contents of this file are subject to the Netscape Public
+ * License Version 1.1 (the "License"); you may not use this file
+ * except in compliance with the License. You may obtain a copy of
+ * the License at http://www.mozilla.org/NPL/
+ *
+ * Software distributed under the License is distributed on an "AS
+ * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
+ * implied. See the License for the specific language governing
+ * rights and limitations under the License.
+ *
+ * The Original Code is mozilla.org code.
+ *
+ * The Initial Developer of the Original Code is Netscape
+ * Communications Corporation.  Portions created by Netscape are
+ * Copyright (C) 1999 Netscape Communications Corporation. All
+ * Rights Reserved.
+ *
+ * This file is Copyright (C) 2001 Hewlett-Packard Co.  All Rights
+ * Reserved.
+ *
+ * Contributor(s):
+ */
+
+/* Platform specific code to invoke XPCOM methods on native objects */
+
+/* contributed by David Mosberger <davidm@hpl.hp.com> */
+
+#include <alloca.h>
+#include <ffi.h>
+
+#include "xptcprivate.h"
+
+static void
+convert_args (PRUint32 n, nsXPTCVariant *params,
+              ffi_type **arg_types, void **args)
+{
+    ffi_type *t;
+    PRUint64 i;
+    void *v;
+#   define CVT(nst,ffit,field)						\
+	case nsXPTType::nst:						\
+		t = &ffit; v = &params[i].val.field; break;
+
+    for (i = 0; i < n; ++i) {
+        if (params[i].IsPtrData()) {
+            arg_types[i] = &ffi_type_pointer;
+            args[i] = &params[i].ptr;
+            continue;
+        }
+        switch (params[i].type) {
+            CVT(T_I8,		ffi_type_sint8,  i8);
+            CVT(T_I16,		ffi_type_sint16, i16);
+            CVT(T_I32,		ffi_type_sint32, i32);
+            CVT(T_I64,		ffi_type_sint64, i64);
+            CVT(T_U8,		ffi_type_uint8,  u8);
+            CVT(T_U16,		ffi_type_uint16, u16);
+            CVT(T_U32,		ffi_type_uint32, u32);
+            CVT(T_U64,		ffi_type_uint64, u64);
+            CVT(T_FLOAT,	ffi_type_float,  f);
+            CVT(T_DOUBLE,	ffi_type_double, u64);
+            CVT(T_BOOL,		ffi_type_sint32, b);
+            CVT(T_CHAR,		ffi_type_schar,  c);
+            CVT(T_WCHAR,	ffi_type_uint32, wc);
+            default:
+              // all the others are plain pointer types
+              t = &ffi_type_pointer;
+              v = &params[i].val.p;
+              break;
+        }
+        arg_types[i] = t;
+        args[i] = v;
+    }
+}
+
+XPTC_PUBLIC_API(nsresult)
+XPTC_InvokeByIndex(nsISupports* that, PRUint32 methodIndex,
+                   PRUint32 paramCount, nsXPTCVariant* params)
+{
+    struct vtable {
+        long offset;		/* offset to beginning of object */
+        unsigned long rtti;	/* address of run-time type info */
+        void (*methods[1]) ();	/* method table (variable length) */
+    } *vtable = *(struct vtable **) that;
+    ffi_type **arg_types;
+    void **args;
+    ffi_status status;
+    ffi_cif cif;
+    nsresult result;
+
+    arg_types = (ffi_type **) alloca((paramCount + 1) * sizeof (arg_types[0]));
+    args = (void **) alloca((paramCount + 1) * sizeof (args[0]));
+
+    arg_types[0] = &ffi_type_pointer;
+    args[0] = &that;
+    convert_args(paramCount, params, arg_types + 1, args + 1);
+    status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, paramCount + 1,
+                          &ffi_type_uint32, arg_types);
+    if (status != FFI_OK)
+        return NS_ERROR_INVALID_ARG;
+
+    ffi_call (&cif, vtable->methods[methodIndex], &result, args);
+    return result;
+}
--- /dev/null	Sat Mar 24 01:35:12 2001
+++ xpcom/reflect/xptcall/src/md/unix/xptcstubs_ffi.cpp	Mon May 14 22:50:58 2001
@@ -0,0 +1,173 @@
+/* -*- Mode: C; tab-width: 8; indent-tabs-mode: nil; c-basic-offset: 4 -*-
+ *
+ * The contents of this file are subject to the Netscape Public
+ * License Version 1.1 (the "License"); you may not use this file
+ * except in compliance with the License. You may obtain a copy of
+ * the License at http://www.mozilla.org/NPL/
+ *
+ * Software distributed under the License is distributed on an "AS
+ * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
+ * implied. See the License for the specific language governing
+ * rights and limitations under the License.
+ *
+ * The Original Code is mozilla.org code.
+ *
+ * The Initial Developer of the Original Code is Netscape
+ * Communications Corporation.  Portions created by Netscape are
+ * Copyright (C) 1999 Netscape Communications Corporation. All
+ * Rights Reserved.
+ *
+ * This file is Copyright (C) 2001 Hewlett-Packard Co.  All Rights
+ * Reserved.
+ *
+ * Contributor(s):
+ */
+
+/* Implement shared vtbl methods.  This implementation should be
+   completely portable except for the mangled name of the stub
+   routines.  */
+
+/* contributed by David Mosberger <davidm@hpl.hp.com> */
+
+#include <alloca.h>
+#include <ffi.h>
+
+#include "xptcprivate.h"
+
+#define MANGLED_STUB_NAME(n)	Stub##n##__14nsXPTCStubBase
+
+static ffi_type *stub_common_arg_types[1] = { &ffi_type_pointer };
+static ffi_cif stub_common_cif;
+
+static void
+get_incoming_args (PRUint32 n, void *raw_args, const nsXPTMethodInfo* info,
+                   nsXPTCMiniVariant *p)
+{
+    ffi_type **arg_types, *t;
+    ffi_status status;
+    ffi_cif cif;
+    void **args;
+    PRUintn i;
+
+    /* create the cif (could be cached): */
+    arg_types = (ffi_type **) alloca ((n + 1) * sizeof (arg_types[0]));
+    arg_types[0] = &ffi_type_pointer;	/* implicit "this" argument */
+    for (i = 0; i < n; ++i) {
+        const nsXPTParamInfo& param = info->GetParam(i);
+        const nsXPTType& type = param.GetType();
+
+        if (param.IsOut() || !type.IsArithmetic()) {
+            arg_types[i + 1] = &ffi_type_pointer;
+            continue;
+        }
+        switch (type) {
+              case nsXPTType::T_I8 :	t = &ffi_type_sint8;  break;
+              case nsXPTType::T_I16:	t = &ffi_type_sint16; break;
+              case nsXPTType::T_I32:	t = &ffi_type_sint32; break;
+              case nsXPTType::T_I64:	t = &ffi_type_sint64; break;
+              case nsXPTType::T_U8 :	t = &ffi_type_uint8;  break;
+              case nsXPTType::T_U16:	t = &ffi_type_uint16; break;
+              case nsXPTType::T_U32:	t = &ffi_type_uint32; break;
+              case nsXPTType::T_U64:	t = &ffi_type_uint64; break;
+              case nsXPTType::T_FLOAT:	t = &ffi_type_float;  break;
+              case nsXPTType::T_DOUBLE:	t = &ffi_type_double; break;
+              case nsXPTType::T_BOOL:	t = &ffi_type_sint32; break;
+              case nsXPTType::T_CHAR:	t = &ffi_type_schar;  break;
+              case nsXPTType::T_WCHAR:	t = &ffi_type_uint32; break;
+
+              default:
+                NS_ASSERTION(0, "bad type");
+                break;
+        }
+        arg_types[i + 1] = t;
+    }
+    status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, n + 1, &ffi_type_uint32,
+                          arg_types);
+    NS_ASSERTION(status = FFI_OK, "status = FFI_OK");
+
+    /* extract the arguments: */
+    args = (void **) alloca((n + 1) * sizeof (args[0]));
+    ffi_prep_incoming_args(&cif, raw_args, args);
+
+    /* fill in the parameter vector: */
+
+    for (i = 0; i < n; ++i) {
+#       define CVT(nst,field,type)                                           \
+	  case FFI_TYPE_##nst: p[i].val.field = *(type *) args[i + 1]; break;
+        switch (arg_types[i + 1]->type) {
+          CVT(SINT8,   i8,  PRInt8);
+          CVT(SINT16,  i16, PRInt16);
+          CVT(SINT32,  i32, PRInt32);
+          CVT(SINT64,  i64, PRInt64);
+          CVT(UINT8,   u8,  PRUint8);
+          CVT(UINT16,  u16, PRUint16);
+          CVT(UINT32,  u32, PRUint32);
+          CVT(UINT64,  u64, PRUint64);
+          CVT(FLOAT,   u32, PRUint32);
+          CVT(DOUBLE,  u64, PRUint64);
+          CVT(POINTER, p,   void *);
+        default:
+          NS_ASSERTION(0, "unexpected ffi type");
+          break;
+        }
+    }
+}
+
+static void xptc_dispatch (ffi_cif *, void *, void **, void *, void *)
+     __asm__("xptc_dispatch") __attribute__((unused));
+
+static void
+xptc_dispatch (ffi_cif *common_cif, void *retp, void **common_args,
+               void *user_data, void *raw_args)
+{
+    uint32 method_index = (long) user_data;
+    nsIInterfaceInfo* iface_info = NULL;
+    const nsXPTMethodInfo* info;
+    nsXPTCMiniVariant *params;
+    nsXPTCStubBase *self;
+    PRUint8 param_count;
+
+    self = *(nsXPTCStubBase **) common_args[0];
+
+    NS_ASSERTION(self, "no self");
+
+    self->GetInterfaceInfo (&iface_info);
+    NS_ASSERTION(iface_info,"no interface info");
+
+    iface_info->GetMethodInfo (PRUint16(method_index), &info);
+    NS_ASSERTION(info,"no interface info");
+
+    param_count = info->GetParamCount ();
+    params = (nsXPTCMiniVariant *) alloca (param_count * sizeof (params[0]));
+    get_incoming_args (param_count, raw_args, info, params);
+
+    *(nsresult *) retp = self->CallMethod ((PRUint16)method_index, info,
+                                           params);
+
+    NS_RELEASE(iface_info);
+}
+
+static class init {
+  public:
+    init (void) {
+        ffi_prep_cif(&stub_common_cif, FFI_DEFAULT_ABI, 1, &ffi_type_pointer,
+                     stub_common_arg_types);
+    }
+} initializer;
+
+#define _STUB(name,arg)                                         \
+  FFI_STATIC_CLOSURE(name, stub_common_cif, xptc_dispatch, arg);
+
+/*
+ * nsresult nsXPTCStubBase::Stub##n()
+ */
+#define STUB_ENTRY(n)	_STUB(MANGLED_STUB_NAME(n), n)
+
+#define SENTINEL_ENTRY(n)                               \
+nsresult nsXPTCStubBase::Sentinel##n()                  \
+{                                                       \
+    NS_ASSERTION(0,"nsXPTCStubBase::Sentinel called");  \
+    return NS_ERROR_NOT_IMPLEMENTED;                    \
+}
+
+#include "xptcstubsdef.inc"

