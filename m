From: Jes Sorensen <jes@sgi.com>
Date: Fri, 28 Apr 2006 07:45:51 +0000
Subject: Re: [patch] update sn2 defconfig
Message-Id: <yq0mze6qh1s.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq07j5bs50k.fsf@jaguar.mkp.net>
In-Reply-To: <yq07j5bs50k.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> > Shouldn't we have this at 10 so we get the most exposure
>> possible.
>> 
>> I'd be fine with that, I just stuck with the default.

Tony> I took this patch as-is ... if you wanto bump this to 10, send
Tony> another patch.

Hi Tony,

No problem, here you go, an update to the update ;) Hand edited, but I
don't see why it shouldn't work ... famous last words!

Cheers,
Jes

An update to the update :) Set node shift to 10 on SN2 and disable
mutex debugging.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/configs/sn2_defconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/arch/ia64/configs/sn2_defconfig
=================================--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig
+++ linux-2.6/arch/ia64/configs/sn2_defconfig
@@ -134,7 +134,7 @@
 CONFIG_ARCH_SPARSEMEM_ENABLE=y
 CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
 CONFIG_NUMA=y
-CONFIG_NODES_SHIFT=8
+CONFIG_NODES_SHIFT
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_HOLES_IN_ZONE=y
 CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
@@ -1159,7 +1159,7 @@
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_PREEMPT=y
-CONFIG_DEBUG_MUTEXES=y
+# CONFIG_DEBUG_MUTEXES is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
 # CONFIG_DEBUG_KOBJECT is not set
