From: Gururaj Ananthateerta <gururaj@cup.hp.com>
Date: Wed, 17 Oct 2001 19:03:14 +0000
Subject: [Linux-ia64] Weird PIO behavior.
Message-Id: <marc-linux-ia64-105590698805362@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am experiencing some bizarre problem when I try to do PIO (memory writes) to
MMIO space for a 64-bits
addressing capable PCI NIC on a Lion platform (The one I have is a 2 processors,
733 MHz Itanium, 1GB RAM).
This problem is on HP-UX and not I haven't tried on Linux (for which I need to
port my driver).

Problem
-----
When multiple PIO writes are in flight, there is something that is
happening that caused  the values to get interchanged.
Something like this below.

Notations
------
Ri = Register i
Vi = Value i intended to be written on Register Ri.


If  the PIO writes are
R1  ------- V1
R2 --------V2
R3 --------V3

The traces on the PCI analyzer shows something like this
R1 --------V2
R2--------V1
R3--------V3

The problem is seen very arbitrary and can be easily reproduced.
Has anyone observed this type of problem or have any clue why this might be
happening.

I somewhere bumped into memory fence and sync instruction.  Do they help me in any
way?.

Thanks for your help
Guru



