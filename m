From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Sep 2004 16:43:27 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409301643.i8UGhRu27470@unix-os.sc.intel.com>
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

 arch/ia64/configs/bigsur_defconfig      | 1132 ++++++++++++++++++++++++++++++++
 arch/ia64/kernel/acpi.c                 |    3 
 arch/ia64/kernel/perfmon.c              |    6 
 arch/ia64/sn/kernel/sn2/prominfo_proc.c |  305 +++-----
 include/asm-ia64/sn/sn_sal.h            |   36 -
 5 files changed, 1311 insertions(+), 171 deletions(-)

through these ChangeSets:

<eranian@hpl.hp.com> (04/09/30 1.1960)
   [IA64] minor fix to perfmon
   
   change the return value of PFM_CREATE_CONTEXT from
   EAGAIN to ENOMEM when the sampling buffer size is
   larger than the RLIMIT_MEMLOCK limit of the task.
   
   signed-off-by: Stephane Eranian <eranian@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<eranian@hpl.hp.com> (04/09/30 1.1959)
   [IA64] perfmon2 fix for TASK_TRACED
   
   fix a problem in pfm_check_task_state() and pfm_task_incompatible()
   which was caused by the introduction of the new TASK_TRACED state.
   Tool would fail to attach to a process,i.e., PFM_LOAD_CONTEXT would
   fail. With the fix perfmon now accepts to operate on tasks which are
   in either TASK_STOPPED or TASK_TRACED state. The problem was tracked
   down by Alex Williamson from HP who also submitted the patch.
   
   signed-off-by: Stephane Eranian <eranian@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/09/29 1.1958)
   [IA64] SMP systems may not have SRAT, still need to mark node0 online.
   
   This only causes a problem in the -mm tree now, but Zou Nan hai and
   Shaohua Li sent me this fix so that SMP systems compiled with the
   generic kernel (which turns on NUMA and CPUSETS in -mm) won't hit
   a BUG_ON in kernel/cpuset.c guarantee_online_mems() which is called
   from acpi_early_init()
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/09/29 1.1957)
   [IA64] defconfig for Intel bigsur
   
   Here's a defconfig that comes up on my box and has a reasonable set of modules
   enabled.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/09/29 1.1956)
   [IA64-SGI] sn2: serialize access to PROM chips
    
   If we read and write the PROM chips at the same time, as might happen at boot
   when salinfo extracts MCA records and a user is checking the PROM revision
   in /proc/sgi_prominfo, an MCA might occur, since the PROM chips can't be
   accessed that way.  This patch fixes the problem for systems with new PROMs
   (>= 3.50) by using the SAL to do PROM reads.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

