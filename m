From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Tue, 03 Sep 2002 16:55:31 +0000
Subject: RE: [Linux-ia64] latest glibc snapshot does not build on ia64?
Message-Id: <marc-linux-ia64-105590701906010@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906009@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906009@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Haven't dug into this too much yet; wanted to see if anyone else has
> seen this?

Yup.

There's a short glibc patch which takes care of this (should be on the
Debian lists, else I can mail it to you once I get my machine back up).
It's an "unofficial"  patch because it's felt the problem really lies 
with binutils and not glibc, so it's not in glibc cvs.   The change
is to dl-machine.h if it helps search...

> 
> CPP='gcc-3.2 -E -x c-header'  
> /home/randolph/debian/glibc-package/ia64-linux/obj
> /elf/ld-linux-ia64.so.2 --library-path 
> /home/randolph/debian/glibc-package/ia64-
> linux/obj:/home/randolph/debian/glibc-package/ia64-linux/obj/m
> ath:/home/randolph
> /debian/glibc-package/ia64-linux/obj/elf:/home/randolph/debian
> /glibc-package/ia6
> 4-linux/obj/dlfcn:/home/randolph/debian/glibc-package/ia64-lin
> ux/obj/nss:/home/r
> andolph/debian/glibc-package/ia64-linux/obj/nis:/home/randolph
> /debian/glibc-pack
> age/ia64-linux/obj/rt:/home/randolph/debian/glibc-package/ia64
> -linux/obj/resolv:
> /home/randolph/debian/glibc-package/ia64-linux/obj/crypt:/home
> /randolph/debian/g
> libc-package/ia64-linux/obj/linuxthreads 
> /home/randolph/debian/glibc-package/ia6
> 4-linux/obj/sunrpc/rpcgen -Y ../scripts -c 
> rpcsvc/bootparam_prot.x -o /home/rand
> olph/debian/glibc-package/ia64-linux/obj/sunrpc/xbootparam_prot.T
> .././scripts/mkinstalldirs 
> /home/randolph/debian/glibc-package/ia64-linux/obj/su
> nrpc/rpcsvc
> Inconsistency detected by ld.so: 
> ../sysdeps/ia64/dl-machine.h: 591: elf_machine_
> rela: Assertion `! "unexpected dynamic reloc format"' failed!
> 
> this is while building glibc 2.2.93 with gcc-3.2.1 (20020830) 
> and binutils
> 2.13.90.0.4 20020814
> 
> randolph
> --  
> Randolph Chung
> Debian GNU/Linux Developer, hppa/ia64 ports
> http://www.tausq.org/
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

