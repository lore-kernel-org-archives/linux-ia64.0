From: tony.luck@intel.com
Date: Fri, 22 Apr 2005 22:03:41 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git

This will update the files shown below.


Thanks!

-Tony

Notes ... this time I used Petr's "cogito" tools, instead of raw git
commands.  I'm hugely impressed that generating the diffstat and commit
list takes less than half a second :-)

"git log" seems to have problems interpreting the dates ... looking at the
commit entries, the time is right ... but it appears that git log applies
the timezone correction twice, so the changes I just applied at 14:46 PDT
look like I made them at quarter to five tomorrow morning (+14 hours from
when I did).

 ia64/ia32/ia32_signal.c |    5 
 ia64/kernel/head.S      |  284 ++++++++++++++++++++++++++++++++++++++++++------
 ia64/kernel/mca_asm.S   |   88 ++++++++------
 ia64/kernel/process.c   |   22 +--
 ia64/kernel/smpboot.c   |   81 ++++++++-----
 asm-ia64/sal.h          |   38 ++++++
 6 files changed, 405 insertions(+), 113 deletions(-)

commit df6c6804ce1d383c878ab071bce8125125d96abc
tree 43765d4b40a4a3c64f2a32b684f4041e2f01644d
parent b8d8b883e6f029e99c35c88f853501740e322131
author Ashok Raj <ashok.raj@intel.com> Sat, 23 Apr 2005 04:46:24 -0700
committer Tony Luck <tony.luck@intel.com> Sat, 23 Apr 2005 04:46:24 -0700

    [IA64] Fix build errors for !HOTPLUG case.
    
    Signed-off-by: Ashok Raj <ashok.raj@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit b8d8b883e6f029e99c35c88f853501740e322131
tree 391f2ade8823149f217991eb02911bf3dacce050
parent 7130667107cd3ab9d6802b69bab63c7d22f20bd4
author Ashok Raj <ashok.raj@intel.com> Sat, 23 Apr 2005 04:44:40 -0700
committer Tony Luck <tony.luck@intel.com> Sat, 23 Apr 2005 04:44:40 -0700

    [IA64] cpu hotplug: return offlined cpus to SAL
    
    This patch is required to support cpu removal for IPF systems. Existing code
    just fakes the real offline by keeping it run the idle thread, and polling
    for the bit to re-appear in the cpu_state to get out of the idle loop.
    
    For the cpu-offline to work correctly, we need to pass control of this CPU 
    back to SAL so it can continue in the boot-rendez mode. This gives the
    SAL control to not pick this cpu as the monarch processor for global MCA
    events, and addition does not wait for this cpu to checkin with SAL
    for global MCA events as well. The handoff is implemented as documented in 
    SAL specification section 3.2.5.1 "OS_BOOT_RENDEZ to SAL return State"
    
    Signed-off-by: Ashok Raj <ashok.raj@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 7130667107cd3ab9d6802b69bab63c7d22f20bd4
tree b4467b2d08a139961e709cfb41bd1f9280249155
parent efab7739d99eae948971140b2aa3dddf7f72c900
author Arun Sharma <arun.sharma@intel.com> Sat, 23 Apr 2005 03:06:47 -0700
committer Tony Luck <tony.luck@intel.com> Sat, 23 Apr 2005 03:06:47 -0700

    [IA64] ia32_signal.c: erroneous use of memset/memcpy
    
    Found by Alexander Nyberg, improved by Bjorn Helgaas.
    
    - Fix the incorrect argument to sizeof()
    - looks like memcpy() code pass was dervived from code that used
      copy_from_user().  But in this case we are doing to kernel space
      to kernel space copy, so memcpy is the right routine, but it
      doesn't return an error code.
     
    Signed-off-by: Arun Sharma <arun.sharma@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

