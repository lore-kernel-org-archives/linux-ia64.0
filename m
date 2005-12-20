From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 20 Dec 2005 18:07:44 +0000
Subject: 2.6.15-rc6 updated perfmon2 patch
Message-Id: <20051220180744.GC5516@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215104604.GA16937@frankl.hpl.hp.com>
In-Reply-To: <20051215104604.GA16937@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfctr-devel@lists.sourceforge.net
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

I have released another verison of the perfmon2 new code base.
This one is relative to 2.6.15-rc6 and hopefully should
fix some of the problems people have reported.

This new kernel patch fixes the following:
	- kernel panic in perfmon_pmu.c or perfmon_fmt.c
	  if PMU description or buffer format is compiled in.

	- missing __user in perfmon_syscalls.c

	- better handling of NMI reservation for X86-64, EM64T
	  and i386.

You MUST use libpfm-3.2-051215 with this kernel due to
interface change for pfm_create_context().

As usual, you can download the latest packages from the
SourceForge website at:

	http://www.sf.net/projects/perfmon2

-- 
-Stephane
