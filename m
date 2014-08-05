From: Kirill Tkhai <tkhai@yandex.ru>
Date: Tue, 05 Aug 2014 21:41:30 +0000
Subject: [Q] sched: __ARCH_WANT_UNLOCKED_CTXSW on IA64
Message-Id: <876351407274890@web12m.yandex.ru>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, IA64 Gurus,

I was looking for the reasons of IA64's __ARCH_WANT_UNLOCKED_CTXSW,
and found the historical commit below:

    commit f8efa27662532ad5adb2790bfc3f4c78e019cfad
    Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
    Date:   Thu Jan 26 18:24:59 2006 -0800

    [IA64] remove staled comments in asm/system.h
    
    With the recent optimization made to wrap_mmu_context function,
    we don't hold tasklist_lock anymore when wrapping context id.
    The comments in asm/system.h must fall through the crack earlier.
    Remove staled comments.
    
    I believe it is still beneficial to unlock the runqueue lock
    across context switch. So leave __ARCH_WANT_UNLOCKED_CTXSW on.
    
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

The comment confuses a reader. It may seem that the #define
is not necessary now, no comment around it at all.

So, could you please point the deadlock we want to avoid
by __ARCH_WANT_UNLOCKED_CTXSW? I've tried to find, but nothing
was found by me. No IA64 machines around, so I can't just
to load kernel w/o this define.

Thanks,
Kirill
