From: Randolph Chung <randolph@tausq.org>
Date: Tue, 03 Sep 2002 16:26:55 +0000
Subject: [Linux-ia64] latest glibc snapshot does not build on ia64?
Message-Id: <marc-linux-ia64-105590701906009@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Haven't dug into this too much yet; wanted to see if anyone else has
seen this?

CPP='gcc-3.2 -E -x c-header'  /home/randolph/debian/glibc-package/ia64-linux/obj
/elf/ld-linux-ia64.so.2 --library-path /home/randolph/debian/glibc-package/ia64-
linux/obj:/home/randolph/debian/glibc-package/ia64-linux/obj/math:/home/randolph
/debian/glibc-package/ia64-linux/obj/elf:/home/randolph/debian/glibc-package/ia6
4-linux/obj/dlfcn:/home/randolph/debian/glibc-package/ia64-linux/obj/nss:/home/r
andolph/debian/glibc-package/ia64-linux/obj/nis:/home/randolph/debian/glibc-pack
age/ia64-linux/obj/rt:/home/randolph/debian/glibc-package/ia64-linux/obj/resolv:
/home/randolph/debian/glibc-package/ia64-linux/obj/crypt:/home/randolph/debian/g
libc-package/ia64-linux/obj/linuxthreads /home/randolph/debian/glibc-package/ia6
4-linux/obj/sunrpc/rpcgen -Y ../scripts -c rpcsvc/bootparam_prot.x -o /home/rand
olph/debian/glibc-package/ia64-linux/obj/sunrpc/xbootparam_prot.T
.././scripts/mkinstalldirs /home/randolph/debian/glibc-package/ia64-linux/obj/su
nrpc/rpcsvc
Inconsistency detected by ld.so: ../sysdeps/ia64/dl-machine.h: 591: elf_machine_
rela: Assertion `! "unexpected dynamic reloc format"' failed!

this is while building glibc 2.2.93 with gcc-3.2.1 (20020830) and binutils
2.13.90.0.4 20020814

randolph
--  
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

