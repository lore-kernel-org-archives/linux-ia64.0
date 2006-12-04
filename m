From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 04 Dec 2006 16:46:44 +0000
Subject: 2.6.19 new perfmon code base + libpfm + pfmon
Message-Id: <20061204164644.GO31914@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net, oprofile-list@lists.sourceforge.net, linux-kernel@vger.kernel.org

Hello,

I have released another version of the perfmon new code base packages.

There is no major updates in this version compared to 061127. This is 
a convenience release so that people can use plain 2.6.19.

The perfmon2 kernel changes are:
	- fix UP exit bug in system-wide mode where the active context
	  accounting was done incorrectly.
	- MIPS update to correct register hardware addresses (Phil Mucci)

I have also released a new libpfm, libpfm-3.2-061204 with the
following changes:
	- updated MIPS processor detection code

Also a new version of pfmon, pfmon-3.2-061204 with the following changes:
	- fix various perfmon v2.0 compatibility bugs for IA-64
	- fortify return values for read() (will Cohen)
	
Both libpfm and pfmon releases work with kernel-patch 061127 or 061204.

You can grab the new packages at our web site:

	 http://perfmon2.sf.net

Enjoy,

-- 
-Stephane
