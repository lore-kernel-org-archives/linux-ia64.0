From: David Mosberger <davidm@hpl.hp.com>
Date: Sun, 30 Sep 2001 16:44:58 +0000
Subject: [Linux-ia64] [patch] additional mozilla fixes
Message-Id: <marc-linux-ia64-105590698805278@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a small patch which makes mozilla/netscape plugins work.
Yes, I finally got tired of mozilla/ia64 crashing whenever visiting, a
site with, e.g., flash content.

Speaking of which: does anyone understand the source policy for the
Macromedia flash player?  If it allows for re-distribution of the
binary, it might be worthwhile to try it out.  I did consider using
the open source flash player from Olivier Odebon
(http://www.swift-tools.com/Flash/).  It can be made to work on ia64,
but it has some problems, e.g., with uncompressed sound, and seems to
make mozilla unstable (though that could be my fault; i used it as an
experiment to teach it esd support... ;-).

	--david

Index: config/mkdepend/imakemdep.h
=================================RCS file: /cvsroot/mozilla/config/mkdepend/imakemdep.h,v
retrieving revision 3.2
diff -u -r3.2 imakemdep.h
--- config/mkdepend/imakemdep.h	1998/09/05 04:22:25	3.2
+++ config/mkdepend/imakemdep.h	2001/09/30 07:29:27
@@ -437,6 +437,9 @@
 # ifdef __i386__
 	"-D__i386__",
 # endif
+# ifdef __ia64
+	"-D__ia64",
+# endif
 # ifdef __GNUC__
 	"-traditional",
 # endif
Index: directory/c-sdk/ldap/libraries/liblber/lber-int.h
=================================RCS file: /cvsroot/mozilla/directory/c-sdk/ldap/libraries/liblber/lber-int.h,v
retrieving revision 1.2.2.3
diff -u -r1.2.2.3 lber-int.h
--- directory/c-sdk/ldap/libraries/liblber/lber-int.h	2001/03/28 00:06:13	1.2.2.3
+++ directory/c-sdk/ldap/libraries/liblber/lber-int.h	2001/09/30 07:29:27
@@ -170,23 +170,22 @@
 	     (((_l)&0xff0000)>>8) + (((_l)&0xff000000)>>24))
 #define LBER_NTOHL(_l) LBER_HTONL(_l)
 
-#elif !defined(__alpha) || defined(VMS)
+#elif !defined(__ia64) && (!defined(__alpha) || defined(VMS))
 
 #define LBER_HTONL( l )	htonl( l )
 #define LBER_NTOHL( l )	ntohl( l )
 
-#else /* __alpha */
+#else /* __alpha || __ia64 */
 /*
- * htonl and ntohl on the DEC Alpha under OSF 1 seem to only swap the
- * lower-order 32-bits of a (64-bit) long, so we define correct versions
- * here.
+ * htonl and ntohl on the 64-bit UNIX platforms only swap the lower-order
+ * 32-bits of a (64-bit) long, so we define correct versions here.
  */
 #define LBER_HTONL( l )	(((long)htonl( (l) & 0x00000000FFFFFFFF )) << 32 \
     			| htonl( ( (l) & 0xFFFFFFFF00000000 ) >> 32 ))
 
 #define LBER_NTOHL( l )	(((long)ntohl( (l) & 0x00000000FFFFFFFF )) << 32 \
     			| ntohl( ( (l) & 0xFFFFFFFF00000000 ) >> 32 ))
-#endif /* __alpha */
+#endif /* __alpha || __ia64 */
 
 
 /* function prototypes */
Index: embedding/browser/activex/src/pluginhostctrl/pluginsdk_include/npapi.h
=================================RCS file: /cvsroot/mozilla/embedding/browser/activex/src/pluginhostctrl/pluginsdk_include/npapi.h,v
retrieving revision 1.1
diff -u -r1.1 npapi.h
--- embedding/browser/activex/src/pluginhostctrl/pluginsdk_include/npapi.h	2001/09/13 12:37:10	1.1
+++ embedding/browser/activex/src/pluginhostctrl/pluginsdk_include/npapi.h	2001/09/30 07:29:28
@@ -58,21 +58,21 @@
 typedef unsigned short uint16;
 #endif
 #ifndef _UINT32
-#if defined(__alpha)
+#if defined(__alpha) || defined(__ia64)
 typedef unsigned int uint32;
-#else /* __alpha */
+#else /* __alpha || __ia64 */
 typedef unsigned long uint32;
-#endif /* __alpha */
+#endif /* __alpha || __ia64 */
 #endif
 #ifndef _INT16
 typedef short int16;
 #endif
 #ifndef _INT32
-#if defined(__alpha)
+#if defined(__alpha) || defined(__ia64)
 typedef int int32;
-#else /* __alpha */
+#else /* __alpha || __ia64 */
 typedef long int32;
-#endif /* __alpha */
+#endif /* __alpha || __ia64 */
 #endif
 
 #ifndef FALSE

Index: include/npapi.h
=================================RCS file: /cvsroot/mozilla/include/npapi.h,v
retrieving revision 3.18
diff -u -r3.18 npapi.h
--- include/npapi.h	2001/09/26 00:39:38	3.18
+++ include/npapi.h	2001/09/30 07:29:41
@@ -164,7 +164,7 @@
 #endif
 
 #ifndef _UINT32
-#    if defined(__alpha)
+#    if defined(__alpha) || defined(__ia64)
 typedef unsigned int uint32;
 #    else  /* __alpha */
 typedef unsigned long uint32;
@@ -180,7 +180,7 @@
 #endif
 
 #ifndef _INT32
-#    if defined(__alpha)
+#    if defined(__alpha) || defined(__ia64)
 typedef int int32;
 #    else  /* __alpha */
 typedef long int32;

