From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 26 Oct 2005 17:38:09 +0000
Subject: patches added to test tree
Message-Id: <200510261738.j9QHc98s004279@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509160423.j8G4NCub007777@agluck-lia64.sc.intel.com>
In-Reply-To: <200509160423.j8G4NCub007777@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patches have been added to the test tree:

Dean Nelson:
      [IA64-SGI] fixes for XPC disengage and open/close protocol
      [IA64-SGI] XPC changes to support more than 2k nasids
      [IA64-SGI] cleanup the way XPC locates the reserved page

H. J. Lu:
      [IA64] Fix 2.6 kernel for the new ia64 assembler

hawkes@sgi.com:
      [IA64] wider use of for_each_cpu_mask() in arch/ia64
      [IA64] another place to use for_each_cpu_mask() in arch/ia64

Peter Chubb:
      [IA64] Allow simulator to use bigger disks

Russ Anderson:
      [IA64-SGI] fix bte_copy() calling get_nasid() while preemptible

Siddha, Suresh B:
      [IA64] fix siblings field value in /proc/cpuinfo

