From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 03 Feb 2003 20:17:01 +0000
Subject: [Linux-ia64] Preempt problems
Message-Id: <marc-linux-ia64-105590709805801@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,
   Just a heads up --- there are still two major problems with the
patch I submitted for preemption support, so I suggest you don't merge
it yet (although I'd very much appreciate having it reviewed and
tested by third parties).

The two problems I see are:
    -- perfmon missing interrupts *even with CONFIG_PREEMPT turned
off!*
   -- weird kernel page faults apparently during ia64_leave_kernel()
(from the stack backtrace), but with an IP address in region 0, after
some variable amount of uptime, apparently independent of anything
happening on the machine (at least, I haven't yet been able to isolate
anything that causes it).

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

