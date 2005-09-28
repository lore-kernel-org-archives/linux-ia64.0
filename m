From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 28 Sep 2005 10:33:31 +0000
Subject: 2.6.14-rc2-mm1 new perfmon2 kernel patch available
Message-Id: <20050928103331.GB3808@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44BDAFB888F59F408FAE3CC35AB4704102225AA9@orsmsx409> <20050928040218.GB3170@frankl.hpl.hp.com>
In-Reply-To: <20050928040218.GB3170@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfctr-devel@lists.sourceforge.net
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hello everyone,

I am pleased to announce that I have released an  updated version
of new-perfmon2 code base. This patch is against 2.6.14-rc2-mm1.

This new releases includes:
	- several bug fixes
	- many performance improvements (a PMD read on Itanium2 is down to 645 cycles).
	- a lot of code simplifications
	- support for P4/Xeon 32-bit (e.g., family 15 model 2).
	  includes support for HyperThreading(HT).
	- a P4/Xeon 32-bit sampling format for Precise Event Based sampling (PEBS)

The patch is known to work for all Itanium processors, P6/Pentium M,
AMD X86-64, P4/Xeon 32-bit. I do not have a lot of user level support for P4 so
testing was limited. Hopefully some people on this list may help with this.
The EM64T is currently broken and must be updated to match the level of
the P4/Xeon 32-bit version. The ppc64 portion has not been tested at all,
it might not even compile.

For all PMU models, the mapping from PMC/PMD to actual PMU registers is
accessible through /proc/perfmon_map. That is useful for people porting
applications from other interfaces.

I encourage everybody to test this patch on their machine and report any
problems.

You can download the new patch from our project website at:

	http://www.sf.net/projects/perfmon2

as release: 2.6.14-rc2-mm1-050928

Enjoy,

-- 
-Stephane
