From: "H . J . Lu" <hjl@valinux.com>
Date: Fri, 05 Jan 2001 17:46:56 +0000
Subject: [Linux-ia64] The 1117 snapshot cpp problem
Message-Id: <marc-linux-ia64-105590678205880@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

My email sent to ia64-tools@napali.hpl.hp.com went to a black hole :-).
I tried it again here.


H.J.
----- Forwarded message from "H . J . Lu" <hjl@valinux.com> -----

Date: Thu, 4 Jan 2001 14:26:30 -0800
From: "H . J . Lu" <hjl@valinux.com>
To: ia64-tools@napali.hpl.hp.com
Subject: The 1117 snapshot cpp problem.
User-Agent: Mutt/1.2.5i

I guess it is a long standing issue in the Cygnus toolchain. The
problem is this change:

--- gcc/configure.in	Fri Dec 22 13:55:48 2000
+++ gcc/configure.in	Thu Aug 17 12:02:45 2000
@@ -136,15 +136,17 @@ AC_ARG_WITH(elf,
 elf="$with_elf",
 elf=no)
 
-# Specify the local prefix
-local_prefix-AC_ARG_WITH(local-prefix,
-[  --with-local-prefix=DIR specifies directory to put local include.],
-[case "${withval}" in
-yes)	AC_MSG_ERROR(bad value ${withval} given for local include directory prefix) ;;
-no)	;;
-*)	local_prefix=$with_local_prefix ;;
-esac])
+# CYGNUS LOCAL: local_prefix
+#local_prefix+#AC_ARG_WITH(local-prefix,
+#[  --with-local-prefix=DIR specifies directory to put local include.],
+#[case "${withval}" in
+#yes)	AC_MSG_ERROR(bad value ${withval} given for local include directory prefix) ;;
+#no)	;;
+#*)	local_prefix=$with_local_prefix ;;
+#esac])
+local_prefix='$(prefix)'
+# END CYGNUS LOCAL
 
 # Default local prefix if it is empty
 if test x$local_prefix = x; then

Bascallly, it sets local_prefix = prefix, which means

$local_prefix/include = $prefix/include

It is ok and desirable for a cross toolchain as long as you don't
install it under /usr as a native compiler. Unfortunately, RedHat/ia64
does exactly that. That means $local_prefix/include = /usr/include.
Now, gcc will search /usr/include before others. It is not very good
for Linux.

# touch l.c
# gcc -M -v l.c
Reading specs from /usr/lib/gcc-lib/ia64-redhat-linux/2.96-ia64-000717/specs
gcc version 2.96-ia64-000717 snap 001117
 /usr/lib/gcc-lib/ia64-redhat-linux/2.96-ia64-000717/cpp ...
GNU CPP version 2.96-ia64-000717 snap 001117 (cpplib)
 (IA-64)
ignoring duplicate directory "/usr/include"
#include "..." search starts here:
#include <...> search starts here:
 /usr/include
 /usr/lib/gcc-lib/ia64-redhat-linux/2.96-ia64-000717/include
 /usr/ia64-redhat-linux/include
End of search list.
l.o: l.c

H.J.

----- End forwarded message -----

