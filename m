From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Sep 2004 05:51:29 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409090551.i895pTs08770@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.9

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/sim/simserial.c |    6 +-----
 arch/ia64/kernel/acpi.c      |    1 +
 arch/ia64/kernel/irq.c       |    2 ++
 arch/ia64/kernel/unwind.c    |   15 +++++++--------
 arch/ia64/mm/discontig.c     |   17 ++++++++++++++---
 arch/ia64/pci/pci.c          |    2 +-
 6 files changed, 26 insertions(+), 17 deletions(-)

through these ChangeSets:

<schwab@suse.de> (04/09/08 1.1803.133.5)
   [IA64] acpi.c: export pm_power_off for use by ipmi_poweroff module.
   
   Signed-off-by: Andreas Schwab <schwab@suse.de>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<mita@yacht.ocn.ne.jp> (04/09/08 1.1803.133.4)
   [IA64] discontig.c: reset counters every iteration each node in show_mem().
   
   On multi-node ia64 system, SysRq-M seems to dump wrong memory info.
   (Since I don't have such a large machine, I don't confirm it)
   It should reset counters every iteration each node in show_mem().
   Jesse Barnes: "This looks good".
    
   Signed-off-by: Akinobu Mita <mita@yacht.ocn.ne.jp>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<willy@debian.org> (04/09/08 1.1803.133.3)
   [IA64] pci.c: assign parent to the ROM resource
   
   Jon Smirl's patch to export roms via sysfs exposes a bug in the ia64
   PCI code; we're not assigning a parent to the ROM resource. Patch
   supplied by Matthew Wilcox
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<janitor@sternwelten.at> (04/09/08 1.1803.133.2)
   [IA64] minmax-removal in simserial.c, unwind.c
    
   Patch (against 2.6.8.1) removes unnecessary min/max macros and changes
   calls to use kernel.h macros instead.
   
   Signed-off-by: Michael Veeck <michael.veeck@gmx.net>
   Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/09/08 1.1803.133.1)
   [IA64] irq.c: Kill warning about variables which are unused in UP kernels.
   
   Signed-off-by: davidm@hpl.hp.com
   Signed-off-by: Tony Luck <tony.luck@intel.com>

