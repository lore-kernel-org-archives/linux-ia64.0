From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Nov 2008 19:56:33 +0000
Subject: unaligned access messages
Message-Id: <200811071956.mA7JuXJd015345@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yesterday I noticed that a few "unaligned access" messages have
shown up in the console boot log:

$ dmesg | grep unaligned
init(1): unaligned access to 0x600000000008b0bb, ip=0x40000000000e3581
init(1): unaligned access to 0x600000000008b0c3, ip=0x40000000000e3620
init(1): unaligned access to 0x600000000008b0c1, ip=0x40000000000e3640
init(1): unaligned access to 0x600000000008c0db, ip=0x40000000000e3581
init(1): unaligned access to 0x600000000008c0e3, ip=0x40000000000e3620
fsck(3193): unaligned access to 0x600000000001255b, ip=0x2000000000069491
fsck(3193): unaligned access to 0x6000000000012563, ip=0x2000000000069530
fsck(3193): unaligned access to 0x6000000000012561, ip=0x2000000000069550
mount(3205): unaligned access to 0x6000000000012c2b, ip=0x2000000000069491
mount(3205): unaligned access to 0x6000000000012c33, ip=0x2000000000069530
mount(3855): unaligned access to 0x6000000000012c6b, ip=0x2000000000069491
mount(3855): unaligned access to 0x6000000000012c73, ip=0x2000000000069530
mount(3855): unaligned access to 0x6000000000012c71, ip=0x2000000000069550

Looking back at my saved logs, i see that this just started in the past
few days.

I tried a git bisect ... and it pinned the blame on this unlikely
looking candidate:

commit 0d13033bc9257fe65c1aa25e84568b1608da0901
Author: Mike Galbraith <efault@gmx.de>
Date:   Fri Oct 24 11:06:14 2008 +0200

    sched: weaken sync hint
    
    Mysql+oltp and pgsql+oltp peaks are still shifted right. The below puts
    the peaks back to 1 client/server pair per core.
    
    Use the avg_overlap information to weaken the sync hint.
    
    Signed-off-by: Mike Galbraith <efault@gmx.de>
    Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

I don't pretend to understand what this change does ... some
very subtle stuff in the scheduler ... but I'm really confused
on how this change could have an effect on the alignment of
data objects in user programs!


Here's some other data points:

1) I don't see this with arch/ia64/configs/tiger_defconfig kernels, just with
arch/ia64/configs/generic_defconfig ones booting on tiger.

2) init, fsck and mount seem to be the only user programs affected.

3) A kernel built from the immediate predecessor to that commit
(1af5f730fc1bf7c62ec9fb2d307206e18bf40a69 - sched: more accurate min_vruntime
accounting) doesn't produce any unaligned messages.  The code change
in the 0d13033b commit generates the same number of bundles of object
code ... so the System.map files are almost identical) ... so this
problem doesn't seem to depend on some freak alignment of some kernel
code/data:

$ diff before/System.map  after/System.map 
28067c28067
< a000000100ae5aa8 t ints.46035
---
> a000000100ae5aa8 t ints.46036
28911c28911
< a000000101247100 d mutex.46924
---
> a000000101247100 d mutex.46925
29978c29978
< a0000001012cc858 d update_runtime_nb.46560
---
> a0000001012cc858 d update_runtime_nb.46561

4) Reverting the 0d13033b commit does not fix the problem in recent
kernels.

5) Changing gcc version (from 4.1.2 to 4.3.1) doesn't have any effect.

Anyone else see this?

Anyone got some other ideas on what to look at to find
out why this is happening?

-Tony
