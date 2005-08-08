From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 08 Aug 2005 21:02:31 +0000
Subject: new perfmon2 kernel patch available
Message-Id: <20050808210230.GA13092@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfctr-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hello,

I have released a new version of the perfmon2  kernel patch
along with a new version of the libpfm user library.

The kernel patch is relative to 2.6.13-rc4-mm1. You need to
apply Andrew Morton's -mm1 to rc4.

This new release includes:
	- update to newer kernel
	- code  reformatting to fit kernel coding style
	- switch from single system call to multi syscalls
	- some more cleanups of macros vs. inline

The patch has been tested on IA-64, Pentium M (with Local APIC)
and X86-64. I have updated the PPC64 but could not test it.

The new version of libpfm is required to exploit the new multi
system call interface. Older versions (incl. 3.2-050701) will
not work. Note that on IA-64, older applications using the
single syscall interface are still supported. At this point,
I have not yet updated the specification document to reflect
the switch to multiple system calls.


You can download the two packages from our new SourceForget.net
project site (still under construction). The new kernel
patch and libpfm are dated 050805.

		http://www.sf.net/projects/perfmon2

Comments welcome.

-- 
-Stephane
