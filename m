From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 26 Apr 2006 14:56:36 +0000
Subject: beta of pfmon-3.2 available
Message-Id: <20060426145636.GA6819@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

Hello,

I have finally released the first beta version of pfmon-3.2.
This version is a major update of version 3.0 released
2 years ago. They are many new features which I hope you'll find
useful.

Here are some of the new features:

	- support for perfmon v2.0 AND perfmon v2.2
	- support for all Itanium processors including Montecito
	- support for AMD X86-64 processors
	- support for Intel Pentium M/P6 processors
	- support for event sets and multiplexing (with perfmon v2.2)
	- instruction-based histrogram sampling module format
	- Data-EAR sampling module formats (Itanium only)
	- ability to exclude idle task for system-wide measurements
	- include or exclude interrupted triggered kernel execution for system
	  wide measurements (Itanium and perfmon v2.2 only )
	- support for rum/sum in monitored binaries (Itanium and perfmon v2.2 only)
	- support for cpu sets
	- man page for generic options

For non Itanium processors, the perfmon v2.2 patch must be applied to the kernel.
You need 2.6.17-rc1 or higher.

The Montecito support is currently missing some of the multi-threading features
as well as the cache MESI options for selected events.

You need libpfm-3.2-060421 or newer to compile pfmon. Similarly you may
want to use libunwind and libiberty to enable certain features. Make sure
you look at the README.

Full documentation including processors specific features is online at our
project's web site.

The tarball can be downloaded from our web site at:
	
		http://perfmon2.sf.net

Please test pfmon in your configuration and report any problems to the
perfmon mailing list.

Enjoy,

--
-Stephane
