From: Bill Nottingham <notting@redhat.com>
Date: Thu, 26 Jul 2001 21:13:37 +0000
Subject: [Linux-ia64] Re: XFree86 4.1.0, Linux/ia64, and various video cards
MIME-Version: 1
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Message-Id: <marc-linux-ia64-105590693005936@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Branden Robinson (branden@progeny.com) said: 
> The tests were conducted using a patched version of 4.1.0 for Debian and
> Progeny that works around a problem with PIC symbols being absent in static
> libraries, which powerpc, ia64, and hppa (among possible others) do not
> tolerate.  At the same time, PIC symbols in X server modules cause the X
> server to segfault.  I'll be submitting this patch to XFree86 shortly.

That's easily fixed with config hackery. I'm surprised this hasn't
been added yet.

Bill

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="XFree86-4.0.1-pic.patch"

--- XFree86-4.0.1/xc/config/cf/Imake.rules.shared	Tue Sep 26 02:25:48 2000
+++ XFree86-4.0.1/xc/config/cf/Imake.rules	Tue Sep 26 02:13:57 2000
@@ -2015,11 +2015,11 @@
  * NormalLibObjCompile - compile fragment for a normal library object file
  */
 #ifndef NormalLibObjCompile
-#define NormalLibObjCompile(options) ObjectCompile(options)
+#define NormalLibObjCompile(options) ObjectCompile(options $(PICFLAGS))
 #endif
 
 #ifndef NormalLibObjCplusplusCompile
-#define NormalLibObjCplusplusCompile(options) ObjectCplusplusCompile(options)
+#define NormalLibObjCplusplusCompile(options) ObjectCplusplusCompile(options $(PICFLAGS))
 #endif
 
 /*

--VbJkn9YxBvnuCH5J--

