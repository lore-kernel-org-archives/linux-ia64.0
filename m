From: Matthew Wilcox <willy@debian.org>
Date: Thu, 09 Oct 2003 19:15:37 +0000
Subject: [PATCH] IO{R,W,RW}_BAD
Message-Id: <marc-linux-ia64-106572723213144@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


We need this patch to compile some drivers.  It's a mirror of the patch
applied to i386 and other architectures.

Index: include/asm-ia64/ioctl.h
=================================RCS file: /var/cvs/linux-2.6/include/asm-ia64/ioctl.h,v
retrieving revision 1.1
diff -u -p -r1.1 ioctl.h
--- include/asm-ia64/ioctl.h	29 Jul 2003 17:01:57 -0000	1.1
+++ include/asm-ia64/ioctl.h	30 Sep 2003 22:23:28 -0000
@@ -54,11 +54,21 @@
 	 ((nr)   << _IOC_NRSHIFT) | \
 	 ((size) << _IOC_SIZESHIFT))
 
+/* provoke compile error for invalid uses of size argument */
+extern int __invalid_size_argument_for_IOC;
+#define _IOC_TYPECHECK(t) \
+	((sizeof(t) = sizeof(t[1]) && \
+	  sizeof(t) < (1 << _IOC_SIZEBITS)) ? \
+	  sizeof(t) : __invalid_size_argument_for_IOC)
+
 /* used to create numbers */
 #define _IO(type,nr)		_IOC(_IOC_NONE,(type),(nr),0)
-#define _IOR(type,nr,size)	_IOC(_IOC_READ,(type),(nr),sizeof(size))
-#define _IOW(type,nr,size)	_IOC(_IOC_WRITE,(type),(nr),sizeof(size))
-#define _IOWR(type,nr,size)	_IOC(_IOC_READ|_IOC_WRITE,(type),(nr),sizeof(size))
+#define _IOR(type,nr,size)	_IOC(_IOC_READ,(type),(nr),(_IOC_TYPECHECK(size)))
+#define _IOW(type,nr,size)	_IOC(_IOC_WRITE,(type),(nr),(_IOC_TYPECHECK(size)))
+#define _IOWR(type,nr,size)	_IOC(_IOC_READ|_IOC_WRITE,(type),(nr),(_IOC_TYPECHECK(size)))
+#define _IOR_BAD(type,nr,size)	_IOC(_IOC_READ,(type),(nr),sizeof(size))
+#define _IOW_BAD(type,nr,size)	_IOC(_IOC_WRITE,(type),(nr),sizeof(size))
+#define _IOWR_BAD(type,nr,size)	_IOC(_IOC_READ|_IOC_WRITE,(type),(nr),sizeof(size))
 
 /* used to decode ioctl numbers.. */
 #define _IOC_DIR(nr)		(((nr) >> _IOC_DIRSHIFT) & _IOC_DIRMASK)

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
