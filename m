From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 18 Jan 2002 02:54:29 +0000
Subject: [Linux-ia64] Fwd: Bug#129641: mozilla illegal instruction fault on IA64 (with a fix)
Message-Id: <marc-linux-ia64-105590698805877@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It was suggested that I forward this here, for the benefit of others
porting mozilla and any other software that relies on the C++ ABI.

Matt


----- Forwarded message from Matt Chapman <matthewc@cse.unsw.edu.au> -----

Package: mozilla-browser
Version: 0.9.7-4
Severity: important

Symptoms: Installation of package fails with "Illegal instruction" fault from
regxpcom; mozilla dies similarly when executing JavaScript.

This seems to be because in recent versions of g++ - since 3.0.2 according to
the ChangeLog - class vtables are arrays of function descriptors (which are
(code address, gp value) pairs) rather than arrays of function pointers (which
are pointers to function descriptors).

The following fix does the trick for me (it's a little evil, but then this kind
of code is necessarily evil :)).

Cheers,
Matt


--- mozilla/xpcom/reflect/xptcall/src/md/unix/xptcinvoke_ffi.old	Sun Jan  6 11:03:05 2002
+++ mozilla/xpcom/reflect/xptcall/src/md/unix/xptcinvoke_ffi.cpp	Thu Jan 17 15:34:56 2002
@@ -83,8 +83,9 @@
         long offset;		/* offset to beginning of object */
         unsigned long rtti;	/* address of run-time type info */
 #endif
-        void (*methods[1]) ();	/* method table (variable length) */
+        unsigned long methods[1];	/* method table (variable length) */
     } *vtable = *(struct vtable **) that;
+    void (*method)();
     ffi_type **arg_types;
     void **args;
     ffi_status status;
@@ -102,6 +103,13 @@
     if (status != FFI_OK)
         return NS_ERROR_INVALID_ARG;
 
-    ffi_call (&cif, vtable->methods[methodIndex], &result, args);
+/* As of g++ 3.0.2, IA64 vtables contain function descriptors - matthewc@cse.unsw.edu.au */
+#if defined(__ia64) && __GNUC__ >= 3 && !(__GNUC__ = 3 && __GNUC_MINOR__ = 0 && __GNUC_PATCHLEVEL__ < 2)
+    method = (void (*)())&vtable->methods[2*methodIndex];
+#else
+    method = (void (*)())vtable->methods[methodIndex];
+#endif
+
+    ffi_call (&cif, method, &result, args);
     return result;
 }

----- End forwarded message -----

