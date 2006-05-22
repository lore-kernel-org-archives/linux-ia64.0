From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 22 May 2006 13:40:40 +0000
Subject: 2.6.17-rc4 new perfmon code base, libpfm, and pfmon releases
Message-Id: <20060522134039.GF30750@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net, oprofile-list@lists.sourceforge.net, linux-kernel@vger.kernel.org

Hello,

I have released another version of the perfmon new code base package.
This release is still relative to 2.6.17-rc4. This is a cumulative
patch, you don't need the previous patch.

This patch introduces two new major features requested by users:

	- support for IA-32 architected PMU as described by the latest
	  IA-32 architecture manuals. You need at least a Core Duo/Solo
	  processors or newer for this to work.

	- a kernel level interface (kapi) to allow kernel code to call
	  perfmon2 for counting and sampling. Only system-wide measurements
	  are supported. Read comments at the top of perfmon_kapi.c

	- PMD write checkers routines for PMU description tables

I have also released a new version of the user library libpfm: libpfm-3.2-060522.
It includes bug fixes for the architected IA-32 PMU support.

Finally, I have released a new version of the pfmon tool. This new version
includes:
	- support for IA-32 architected PMU (includes Core Duo/Solo processors)
	- bug fixes in the i386 P6/PM support

This version of pfmon-3.2 requires libpfm-3.2-060522.

You can grab the new packages at our web site:

	 http://perfmon2.sf.net

The libpfm and pfmon source code is also available in our CVS repository
accessible from our home page.

Enjoy,

-- 
-Stephane
