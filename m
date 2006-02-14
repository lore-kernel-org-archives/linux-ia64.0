From: Ashok Raj <ashok.raj@intel.com>
Date: Tue, 14 Feb 2006 23:01:10 +0000
Subject: [patch 0/2] Do not set cpu_possible_map to NR_CPUS bits when CPU hotplug is enabled
Message-Id: <20060214230109.997471398@csdlinux-2.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

here is patch to not set NR_CPUS bits in cpu_possible_map when 
CONFIG_HOTPLUG_CPU is enabled. This just restricts the cpu_possible_map
to a more reasonable number. We now count the number of disabled cpus in
MADT as potentially hotpluggable cpus. In case thats not true, parameter 
additional_cpus=x can be used at startup to add extra bits to cpu_possible_map.


Will be good to fix it before 2.6.16 gets released. Other arch code is mostly
checked in already I think.

Cheers,
ashok

