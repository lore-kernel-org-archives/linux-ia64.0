From: Alan Au <alanau@cse.unsw.EDU.AU>
Date: Thu, 17 Aug 2000 01:56:35 +0000
Subject: Re: [Linux-ia64] building glibc
Message-Id: <marc-linux-ia64-105590678205341@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 16 Aug 2000, H . J . Lu wrote:

> Your kernel header files are too old.

Thanks. You were right. 

It gets a bit furthur now but gets the following error:

make[2]: Entering directory `/home/alanau/src/glibc/glibc-2.1-hjl/sunrpc'
/home/alanau/glibc-build/elf/ld-linux.so.2 --library-path
/home/alanau/glibc-build:/home/alanau/glibc-build/math:/home/alanau/glibc-build/elf:/home/alanau/glibc-build/nss:/home/alanau/glibc-build/nis:/home/alanau/glibc-build/db2:/home/alanau/glibc-build/rt:/home/alanau/glibc-build/resolv
/home/alanau/glibc-build/sunrpc/rpcgen -Y `gcc -print-file-name=cpp | sed
"s|/cpp$||"` -c rpcsvc/bootparam_prot.x -o
/home/alanau/glibc-build/sunrpc/xbootparam_prot.T
doSyscall: unimplemented system call 1212
/home/alanau/glibc-build/sunrpc/rpcgen: error in loading shared
libraries: /home/alanau/glibc-build/sunrpc/rpcgen: cannot stat shared
object: Error 38
make[2]: *** [/home/alanau/glibc-build/sunrpc/xbootparam_prot.stmp] Error
127


In fact, get the same error if I invoke the newly built ld.so directly:

bash$ pwd
/home/alanau/glibc-build/elf
bash$ ./ld.so ~/tmp/a.out
doSyscall: unimplemented system call 1212
/home/alanau/tmp/a.out: error in loading shared
libraries: /home/alanau/tmp/a.out: cannot stat shared object: Error 38


Not sure if this is an NUE problem.

Thanks.

Alan
__________
alanau@cse.unsw.edu.au
School of Computer Science and Engineering
University of New South Wales


