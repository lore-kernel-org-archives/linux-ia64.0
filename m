From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Sep 2004 22:39:11 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409162239.i8GMdBM01917@unix-os.sc.intel.com>
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

 arch/ia64/Kconfig                       |    6 
 arch/ia64/kernel/minstate.h             |    6 
 arch/ia64/sn/kernel/sn2/Makefile        |    2 
 arch/ia64/sn/kernel/sn2/prominfo_proc.c |    2 
 arch/ia64/sn/kernel/sn2/sn_hwperf.c     |  652 ++++++++++++++++++++++++++++++++
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c    |    7 
 include/asm-ia64/mca_asm.h              |    3 
 include/asm-ia64/sn/sn2/sn_hwperf.h     |  218 ++++++++++
 include/asm-ia64/sn/sn_sal.h            |   18 
 9 files changed, 905 insertions(+), 9 deletions(-)

through these ChangeSets:

<markgw@sgi.com> (04/09/16 1.1867.3.7)
   [IA64] SGI Altix hardware performance monitoring API
    
     
   The SGI Altix PROM supports a SAL call for performance monitoring and for
   exporting NUMA topology. We need this in community kernels for diagnostic
   and performance tools to use, especially on very large machines.
   
   This patch registers a dynamic misc device "sn_hwperf" that supports an
   ioctl interface for reading/writing memory mapped registers on Altix
   nodes and routers via the new SAL call. It also creates a read-only
   procfs file "/proc/sgi_sn/sn_topology" to export NUMA topology and Altix
   hardware inventory.
   
   > What tools are using this?
    
   Performance Co-Pilot http://oss.sgi.com/projects/pcp  in particular,
   pmshub, shubstats and linkstat. Numerous other users include anything
   that needs knowledge of numa topology/interconnect in order to perform
   well, e.g. mpt. BTW I have not exported any API functions .. at this
   point I don't think we need any modules to call the API.
   
   Signed-off-by: Mark Goodwin <markgw@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/09/16 1.1867.3.6)
   [IA64] Kconfig: Add help text for IA64_SGI_SN2 config option.
   
   Mark Goodwin suggested that we document our platform a bit.  This patch adds
   help text for the sn2 specific kernel option.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kaos@sgi.com> (04/09/16 1.1867.3.5)
   [IA64] ar.k[56] have virtual addresses already, don't convert
   
   r.k[56] used to contain physical addresses but now contain virtual
   addresses.  There are code remnants which still believe that they are
   physical and "convert" ar.k[56] to virtual.  This breaks when current
   is not in region 7 (e.g. the idle task on cpu 0).
    
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/09/15 1.1867.3.4)
   [IA64-SGI]: fix `qw' might be used uninitialized warning
   
   The compiler has no way of knowing whether nentries will be greater than 0, so
   it was generating a warning that qw might be used uninitialized.  Fix it by
   explicitly setting it to 0.  Cc'ing Brian in case he has an internal version
   he'd like to keep in sync.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/09/15 1.1803.151.8)
   [IA64] make INIT dump work again
   
   current can be in region 5, use 'tpa' to convert to physical
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

