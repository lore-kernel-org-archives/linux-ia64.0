From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 01 Oct 2004 16:42:32 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200410011642.i91GgWI07522@unix-os.sc.intel.com>
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

 arch/ia64/Kconfig              |    3 
 arch/ia64/kernel/Makefile      |    2 
 arch/ia64/kernel/mca.c         |   41 ++
 arch/ia64/kernel/mca_drv.c     |  643 ++++++++++++++++++++++++++++++++++++++++-
 arch/ia64/kernel/mca_drv.h     |  113 +++++++
 arch/ia64/kernel/mca_drv_asm.S |   45 ++
 include/asm-ia64/mca.h         |    9 
 7 files changed, 847 insertions(+), 9 deletions(-)

through these ChangeSets:

<tony.luck@intel.com> (04/09/30 1.2022)
   [IA64] mca.h, mca_drv.c: cleanup extern declarations
   
   Move extern declarations of ia64_{reg,unreg}_MCA_extension()
   to mca.h.  Delete declaration of ia64_mca_ucmc_other_recover_fp()
   which doesn't exist.
   
   Patch supplied by Hidetoshi Seto.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<seto.hidetoshi@jp.fujitsu.com> (04/09/30 1.2021)
   [IA64] Recovery from user-mode memory error
   
   This is the latest/Updated OS_MCA handler which try to do recovery
   from multibit-ECC/poisoned memory-read error on user-land.
   (Thank you very much for comments, Keith and Grant!)
   
   I'd still appreciate it if anyone having good test environment
   could apply my patch and could report how it works.
   (especially reports on non-Tiger/non-Intel platform are welcome.)
   
   Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

