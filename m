From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Mon, 20 Sep 2004 16:25:20 +0000
Subject: PATCH-ACPI based CPU hotplug[0/6]
Message-Id: <20040920092520.A14208@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <len.brown@intel.com>, ACPI Developer <acpi-devel@lists.sourceforge.net>, LHNS list <lhns-devel@lists.sourceforge.net>
Cc: Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Hi Len,
  I am resending the following set of patches which support ACPI based physical 
CPU hotplug for IA64 platform, after having including all the community 
feedback(of course I got very thin feedback) which I got on 
acpi-devel mailing list.

This set of patches has been tested on linux-2.6.9-rc2. Also this time I am 
cc'ing ia64/lkml mailing lists as patch 3/6 and patch 4/6 touches arch specific files.

Details:(Applies cleanly onto linux-2.6.9-rc2)
Patch[1/6]- Core ACPI enhancement support
Patch[2/6]- ACPI hotplug eject interface support
Patch[3/6]- Arch specific support for mapping lsapic to cpu
Patch[4/6]- Dynamic cpu registration and unregistration support
Patch[5/6]- Extend ACPI processor driver to support Hotplug
Patch[6/6]- ACPI container driver(New driver)

Please consider applying this patch onto your test tree.

Thanks,
Anil S Keshavamurthy
