From: Matt_Domsch@Dell.com
Date: Mon, 21 Feb 2000 04:00:21 +0000
Subject: RE: [Linux-ia64] building the toolchain
Message-Id: <marc-linux-ia64-105590678204945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204943@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204943@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I managed to get the IA-64 2-16-2000 toolchain built using egcs-2.91.66 from
Red Hat 6.1 on an IA32 platform.
The only trouble I had was with 'make install prefix=/usr/local/ia64/'
command, where the Makefile in build/itcl/iwidgets3.0.0/unix needed to be
fixed a bit, to point to the TCL and TK directories within the top-level src
directory.  Here's my patch (of course, it'll have to be fixed to show your
own src directory).  Without the patch, 'make install' failed trying to
execute mkinstalldirs under the itcl directory.

What I haven't yet seen is a glibc release (with include files) that lets
you build even simple IA64 apps.  With no stdio.h anywhere on the Trillian
2-2-2000 CD, one can't compile the simplest hello world app, even though the
compiler looks like it would do it if glibc were present.

Thanks,
Matt Domsch
Dell Enterprise Systems Group
Linux Development Team


diff -burN build/itcl/iwidgets3.0.0/unix/Makefile~
build/itcl/iwidgets3.0.0/unix/Makefile
--- build/itcl/iwidgets3.0.0/unix/Makefile~     Sun Feb 20 18:05:16 2000
+++ build/itcl/iwidgets3.0.0/unix/Makefile      Sun Feb 20 21:16:12 2000
@@ -77,25 +77,29 @@
 TCL_LIB_DIR = /usr/lib
 
 # Directory containing Tcl source code (for library used during test):
-TCL_SRC_DIR = /usr/src/bs/BUILD/tcltk-8.0.5/tcl8.0.5
+#TCL_SRC_DIR = /usr/src/bs/BUILD/tcltk-8.0.5/tcl8.0.5
+TCL_SRC_DIR = /home/mdomsch/gnupro/src/tcl
 
 # Tk libraries can be found here:
 TK_LIB_DIR = /usr/lib
 
 # Directory containing Tk source code (for library used during test):
-TK_SRC_DIR = /usr/src/bs/BUILD/tcltk-8.0.5/tk8.0.5
+#TK_SRC_DIR = /usr/src/bs/BUILD/tcltk-8.0.5/tk8.0.5
+TK_SRC_DIR = /home/mdomsch/gnupro/src/tk
 
 # Itcl libraries can be found here:
 ITCL_LIB_DIR = /usr/lib
 
 # Directory containing Itcl source code (for library used during test):
-ITCL_SRC_DIR = /usr/src/bs/BUILD/tcltk-8.0.5/itcl3.0.1/itcl
+#ITCL_SRC_DIR = /usr/src/bs/BUILD/tcltk-8.0.5/itcl3.0.1/itcl
+ITCL_SRC_DIR = /home/mdomsch/gnupro/src/itcl
 
 # Itk libraries can be found here:
 ITK_LIB_DIR = /usr/lib
 
 # Directory containing Itk source code (for library used during test):
-ITK_SRC_DIR = /usr/src/bs/BUILD/tcltk-8.0.5/itcl3.0.1/itk
+#ITK_SRC_DIR = /usr/src/bs/BUILD/tcltk-8.0.5/itcl3.0.1/itk
+ITK_SRC_DIR = /home/mdomsch/gnupro/src/itk
 
 # [incr Tk] build directory containing the itkwish binary for 'make test'
 ITK_BIN_DIR = ../../itk/unix
@@ -113,7 +117,7 @@
 INSTALL =              /usr/bin/install -c
 INSTALL_PROGRAM =      $(INSTALL)
 INSTALL_DATA =         $(INSTALL) -m 644
-MKINSTALLDIRS =                $(ITCL_SRC_DIR)/../config/mkinstalldirs
+MKINSTALLDIRS =                $(ITCL_SRC_DIR)/config/mkinstalldirs
 RANLIB =               ranlib
 TOP_DIR =              /home/mdomsch/gnupro/src/itcl/iwidgets3.0.0
 GENERIC_DIR =          $(TOP_DIR)/generic


-----Original Message-----
From: Uros Prestor [mailto:uros@turbolinux.com]
Sent: Sunday, February 20, 2000 2:18 PM
To: Tim Riker
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] building the toolchain


Tim Riker <TimR@CalderaSystems.com> said: 

> I've been trying to build and use these tools. I believe I am missing
> some step along the way. I'm starting with the cross compiler and
> attempting to build a new kernel. Here's what I've done:

I have tried building the native cpmpiler with a cross compiler
but I pretty much gave up.  There might be some magic options
for configure but I haven't figured them out.

I have build a native compiler with the September release of the compiler.
You can grab the native compiler on bunyip in ~jes/usr_local-110100.tar.gz.

Uros

--
Uros Prestor
uros@turbolinux.com




_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


