From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 27 Jul 2000 19:35:44 +0000
Subject: [Linux-ia64] GLIBC __deregister_frame_pointer compiler error
Message-Id: <marc-linux-ia64-105590678205235@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

While trying to compile glibc on the 2.4 kernel, I get the error messages
included below.  On 2.3.99, everything compiles fine.  Any ideas where to
look to solve this?

Thanks
Mike Madore
Software Engineer
TurboLinux, Inc.

gcc -nostdlib -nostartfiles -o 
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcinfo  
   -Wl,-dynamic-linker=/lib/ld-linux-ia64.so.1   
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/csu/crt1.o 
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/csu/crti.o 
   `gcc --print-file-name=crtbegin.o` 
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcinfo.o  
   -Wl,-rpath-link=/usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/math:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/elf:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/nss:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/nis:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/db2:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/rt:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/resolv:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/linuxthreads 
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/libc.so.0 
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/libc_nonshared.a -lgcc 
   `gcc --print-file-name=crtend.o` 
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/csu/crtn.o
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/elf/ld-linux-ia64.so.1 
   --library-path /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/math:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/elf:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/nss:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/nis:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/db2:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/rt:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/resolv:
      /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/linuxthreads 
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcgen -Y 
   `gcc -print-file-name=cpp | sed "s|/cpp$||"` -c rpcsvc/bootparam_prot.x 
   -o /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/xbootparam_prot.T

/usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcgen: 
   : no version information available 
(required by /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcgen)

/usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcgen: 
   : no version information available 
   (required by /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcgen)

/usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcgen: 
   error in loading shared libraries: 
   /usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc/rpcgen: 
   symbol __deregister_frame_info, version GLIBC_2.0 not defined in file libc.so.0 
   with link time reference

make[2]: *** [/usr/src/turbo/BUILD/glibc-2.1-hjl/build-ia64-linux/sunrpc
   /xbootparam_prot.stmp] Error 127

make[2]: Leaving directory `/usr/src/turbo/BUILD/glibc-2.1-hjl/sunrpc'
make[1]: *** [sunrpc/others] Error 2
make[1]: Leaving directory `/usr/src/turbo/BUILD/glibc-2.1-hjl'
make: *** [all] Error 2
Bad exit status from /var/tmp/rpm-tmp.21464 (%build)



