From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 21 Sep 2004 20:09:47 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409212009.i8LK9l526704@unix-os.sc.intel.com>
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

 arch/ia64/configs/sn2_defconfig |   17 +++++-----
 arch/ia64/ia32/binfmt_elf32.c   |   39 +++++++++++++++++++++++
 arch/ia64/ia32/ia32_entry.S     |    4 +-
 arch/ia64/ia32/ia32_signal.c    |   33 +++++++++++++------
 arch/ia64/ia32/ia32_support.c   |   28 ++++++++++++++--
 arch/ia64/ia32/ia32priv.h       |   11 ++++--
 arch/ia64/ia32/sys_ia32.c       |   67 ----------------------------------------
 arch/ia64/mm/init.c             |    2 -
 include/asm-ia64/ia32.h         |    2 -
 9 files changed, 108 insertions(+), 95 deletions(-)

through these ChangeSets:

<jbarnes@sgi.com> (04/09/21 1.1867.3.8)
   [IA64] sn2_defconfig update take 2
    
   Please apply this one instead.  It turns on mmtimer and increases the number
   of sg entries for the LSI driver.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<gordon.jin@intel.com> (04/09/21 1.1915)
   [IA64] ia32compat: Disable syscalls sys32_iopl() and sys32_ioperm() on ia64.
   
   Disable syscalls sys32_iopl() and sys32_ioperm() on ia64.
   To emulate these 2 syscalls correctly, we need to guarantee uncached
   memory attributes on ia64, which is difficult. The only user of this
   interface that we know of is X. So we think it's better to disable it.
    
   Signed-off-by: Gordon Jin <gordon.jin@intel.com>
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kevin.tian@intel.com> (04/09/21 1.1914)
   [IA64] ia32compat: Put signal restorer code on a gate page
   
   When userland doesn't specify sigaction->sa_restorer, we try to put
   the restorer code on the stack. But this breaks ia32 binaries with
   non-executable stacks. We now put the restorer code on a gate page.
    
   Signed-off-by: Kevin Tian <kevin.tian@intel.com>
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

