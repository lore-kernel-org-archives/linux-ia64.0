From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 16 Dec 2003 16:09:54 +0000
Subject: Link error with gcc-3.3
Message-Id: <marc-linux-ia64-107159101718747@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,

I haven't seen anyone else complain about this yet, so I will.

The latest linux-ia64-2.5 bk fails to link with the following error
while using gcc-3.3 from debian-sid:

  CHK     include/linux/compile.h
  UPD     include/linux/compile.h
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
arch/ia64/kernel/built-in.o(__ksymtab+0x5a0): undefined reference to `ia64_spinlock_contention_pre3_4'
make: *** [.tmp_vmlinux1] Error 1
mort@green:/usr/src/linux-ia64-2.5$


mort@green:/usr/src/linux-ia64-2.5$ gcc -v
Reading specs from /usr/lib/gcc-lib/ia64-linux/3.3.2/specs
Configured with: ../src/configure -v --enable-languages=c,c++,java,f77,pascal,objc,ada,treelang --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-gxx-include-dir=/usr/include/c++/3.3 --enable-shared --with-system-zlib --enable-nls --without-included-gettext --enable-__cxa_atexit --enable-clocale=gnu --enable-debug --enable-java-gc=boehm --enable-java-awt=xlib --enable-objc-gc ia64-linux
Thread model: posix
gcc version 3.3.2 (Debian)


The same tree works fine if I compile with "make -j3 compressed CC=gcc-3.2"
thanks
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296
