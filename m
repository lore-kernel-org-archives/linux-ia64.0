From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Feb 2006 01:06:51 +0000
Subject: patches added to release tree
Message-Id: <200602160106.k1G16p67025504@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patches have been added to the release tree and I'll
send them on to Linus soon.  I think this answers all the pleas for
please put this into 2.6.16, but if I missed something, please send
me an e-mail.  Still processing Jack's TIF_WORK patch.

Andreas Schwab:
      [IA64] Remove duplicate EXPORT_SYMBOLs

Ashok Raj:
      [IA64] Dont set NR_CPUS for cpu_possible_map when CPU hotplug is enabled.
      [IA64] Count disabled cpus as potential hot-pluggable CPUs

Dean Nelson:
      [IA64-SGI] enforce proper ordering of callouts by XPC

Dean Roe:
      [IA64-SGI] fix the size of __sn_cnodeid_to_nasid

hawkes@sgi.com:
      [IA64] ia64: simplify and fix udelay()

Horms:
      [IA64] support panic_on_oops sysctl

Jes Sorensen:
      [IA64-SGI] sn2 minor fixes and cleanups
      [IA64] remove obsolete corporate address
      [IA64-SGI] remove compile time warning

Mark Maule:
      [IA64-SGI] export sn_pcidev_info_get
