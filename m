From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 08 Jun 2005 21:59:46 +0000
Subject: perfmon2 new code base Update 1
Message-Id: <20050608215945.GH21554@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

I am happy to announce an updated version of the code for
the new perfmon code base. This update fixes several important
problems and incorporates many cleanups. I would like to thank
all the people who have provided feedback and I certainly
welcome more of it.

This update is relative to 2.6.12-rc6. Here is an excerpt
of the ChangeLog:
	* fixed Pentium M counter width to 40 (from invalid 32)
	* fixed in-flight overflow handling for non IA-64
	* fixed timeout-based set switching from non IA-64
	* removed unused pfm_arch_ callbacks
	* reformatted code to 80 column wherever possible
	* reformatted if/then/else
	* fixed pfm_arch_monitoring_is_active() for non IA-64
	* fixed race condition in pfm_do_interrupt_handler()
	* added generic carta_random32() routine
	* regrouped IA-64 old perfmon2 compatbility code in perfmon_compat.c
	* updated pfm_ovfl_msg_t with new fields for user level sampling
	* use custom nopage handler to remap kernel level sampling buffer

Again this is not for production nor mainline at this point. This is
for OS and tools developers. There are some known bugs on Pentium M
in particular and some features are still incomplete.

You can grab the package at:
	ftp://ftp.hpl.hp.com/pub/linux-ia64/perfmon-new-base-050608.tar.gz
	MD5SUM: b608274d1211c43b65c662136a0e6d1f

Enjoy,

-- 
-Stephane
