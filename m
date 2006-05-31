From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 31 May 2006 20:25:17 +0000
Subject: q-tools-0.3 with Montecito support available
Message-Id: <20060531202517.GA28861@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I have finally released version 0.3 of David's q-tools
monitoring tool for Linux/ia64.

New features:
	- support for Dual-Core Itanium 2 (Montecito) processor

This tool works only on Itanium 2 and follow-on processor. It does not
work on the first generation Itanium (Merced) processor.

Requirements:

	- you need libpfm-3.2-060512 or newer to compile. On Debian you
	  need to grab libpfm3 from unstable. Otherwise, you can get a
	  copy at:
			http://perfmon2.sf.net

	- to run on Montecito, you need Montecito support in the kernel.
	  The mainline kernel, 2.6.16 and higher, has the required support.
	  SLES10 is known to have support. As for RHEL4, I think you would
	  need U5 (to be verified). You can check whether you have support
	  by looking at /proc/perfmon and the PMU model line. If it does not
	  say Montecito, this will not work.

	- On non-Montecito, the tool works all kernel 2.6.5 or higher.

	- this version works also with perfmon v2.2 (aka new code base) for
	  all Itanium processors, including Montecito. As this point, v2.2
	  requires a kernel patch which you can get at the web site mentioned
	  above.

You can grab the latest version of q-tools at:
	ftp://ftp.hpl.hp.com/pub/linux-ia64/q-tools-0.3.tar.gz
	MD5SUM: 3f9e5230fe258c2baa288d9c70fc73b2

Enjoy,

-- 
-Stephane
