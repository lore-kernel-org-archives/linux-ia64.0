From: Uros Prestor <uros@turbolinux.com>
Date: Fri, 12 Jan 2001 19:36:48 +0000
Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590693005039@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Mallick, Asit K" wrote:

> Attached is a patch to fix the problem. Uros and Jenna were able to boot
> with this patch. Sorry for sending the early version.

Something is still not kosher if you enable CONFIG_DISABLE_VHPT=y.  If I try
recompiling the gnupro RPM the compilation breaks down immediately after the
config stage With the following error:

     # rpm -ba /usr/src/turbo/SPECS/gnupro.spec
     ...
     creating ./config.status
     creating Makefile
     Configuring utils...
     Created "Makefile" in /work/BUILD/gnupro-2.96/build/utils
     Configuring spu...
     Created "Makefile" in /work/BUILD/gnupro-2.96/build/utils/spu
     ++ perl -e 'if( -x "/usr/bin/getconf" &&  ( ($p=`/usr/bin/getconf
     _NPROCESSORS_ONLN`) >= 0 ) ){ print "$p"} else { print "1"; }'
     + make -j 2
     /bin/sh: SHELL: command not found
     /bin/sh: -c: command not found
     make: *** [all-libiberty] Error 127
     make: *** Waiting for unfinished jobs....
     Bad exit status from /var/tmp/rpm-tmp.82077 (%build)

Things become very bizarre if you try to compile by hand, ranging from
reports of missing /lib/libc.so.6.1 to internal compiler errors...  This
happens both on 2xB3 BigSur and 4xB3 Lion.  If I revert to the kernel which
enables VHPT the compilation goes just fine.

Uros

--
Uros Prestor
uros@turbolinux.com




