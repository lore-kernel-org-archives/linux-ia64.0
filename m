From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 31 Jul 2002 23:36:10 +0000
Subject: [Linux-ia64] official SPECfp results for Itanium 2
Message-Id: <marc-linux-ia64-105590701905868@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thought it might be of interest to this readership that, for the first
time ever, linux has become the world-leader in published SPECfp2000
performance!

The details are at:

  http://www.specbench.org/osg/cpu2000/results/res2002q3/cpu2000-20020715-01485.html

A quick summary goes like this:

  SPECfp_base2000 = 1356
	CPU: 1000MHz Itanium 2
    machine: zx6000 workstation
	 OS: Debian 3.0 Linux with 2.4.18 kernel
   compiler: Intel C++ and Fortran Compiler 6.0.1 for Linux

To be fair, I need to mention that hp-ux currently gets higher SPECint
numbers on Itanium 2 (and, no, there are no ia64 linux SPECint numbers
at specbench.org; don't ask me why---I simply don't know as I'm not
directly involved with SPECmarking...).  The reason for this is that
the nature of the SPECint benchmarks causes Linux to pay the full cost
of the LP64 data model without reaping any of the benefits (hopefully,
this is an issue that will be addressed by SPECcpu2004).  Also, Linux
could benefit from superpage support to reduce TLB-pressure on some of
the benchmarks and compiler improvements would always help as well, of
course.

Enjoy,

	--david

