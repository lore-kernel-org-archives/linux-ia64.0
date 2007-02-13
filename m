From: William Cohen <wcohen@redhat.com>
Date: Tue, 13 Feb 2007 21:40:18 +0000
Subject: Re: [perfmon] 2.6.20 new perfmon code base + libpfm + pfmon
Message-Id: <45D23042.1020802@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070213184839.GC10031@frankl.hpl.hp.com>
In-Reply-To: <20070213184839.GC10031@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: perfmon@napali.hpl.hp.com, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net

Stephane Eranian wrote:
> Hello,
> 
> I have released another version of the perfmon new code base package.
> This version of the kernel patch is relative to 2.6.20.
> 
> This  new kernel patch includes the following new features and
> bug fixes:
> 	- first cut at supporting Oprofile on i386 and x86-64 architectures
> 	- several internal interfaces simplfications
> 	- various MIPS updates (Phil Mucci/Manoj Ekbote)
> 	- varous PPC32 updates (Phil Mucci)
> 	- fix bug in set switching with a single set
> 	- fix bug in pfm_restart() for per-thread mode with blocking notification
> 
> Unfortunately, this release does not build for PowerPC due to a problem with the
> TIF_* flags. Perfmon adds 2 new flags which make the TIF now use more than 16 bits which
> causes problem with some assembly instructions in entry_64.S. Hopefully,
> this will be fixed in the next release.
> 
> To make Oprofile work, you need a modified user level Oprofile package. I have made
> a first pass at modifying 0.9.2 to work on Perfmon 2.3 (and v2.0 for IA-64) for
> the following processors: AMD Opteron, P6, Core Duo, Core 2 Duo, P4. The modified
> package is available as Alpha at:
> 
> 	ftp://ftp.hpl.hp.com/pub/linux-ia64/oprof-perfmon2-070122.diff

Hello Stephane,

The oprofile patch should be made against the oprofile cvs rather than the 0.9.2 
tarball. There are some files that the patch touches that are created by the 
autogen.sh.

The oprofile patch doesn't build if things are configured without the 
"--enable-perfmon2".

gcc -W -Wall -fno-common -Wdeclaration-after-statement -fno-omit-frame-pointer 
-g -O2   -o oprofiled  init.o oprofiled.o opd_stats.o opd_sfile.o opd_kernel.o 
opd_trans.o opd_cookie.o opd_events.o opd_mangling.o opd_perfmon.o 
opd_perfmon_22.o opd_perfmon_compat.o opd_anon.o liblegacy/liblegacy.a 
../libabi/libabi.a ../libdb/libodb.a ../libop/libop.a ../libutil/libutil.a 
-lpopt -liberty -ldl
opd_perfmon.o: In function `perfmon_init':
/home/wcohen/research/profiling/oprofile/oprofile-0.9.2-perfmon2/daemon/opd_perfmon.c:384: 
undefined reference to `do_perfmon_init'
collect2: ld returned 1 exit status

-Will
