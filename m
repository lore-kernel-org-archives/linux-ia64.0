From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 13 Feb 2002 18:53:51 +0000
Subject: [Linux-ia64] O(1) scheduler patch and IA64
Message-Id: <marc-linux-ia64-105590698806043@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm trying to apply the K3 version of Ingo Molnar's O(1) scheduler patch
to kernel 2.4.17 + linux-2.4.17-ia64-011226.  I'm able to get everything
to apply cleanly, however compilations on UP kernel configurations are
broken.  The new patch conditionally defines the schedule_tail function
in kernel/smp.c based on the value of CONFIG_SMP.  The patch also
conditionally calls this function in arch/i386/kernel/entry.S.  The
patch doesn't address IA64, so entry.S still references the function,
even when CONFIG_SMP is not set.

What code should be conditionally compiled on IA64 in entry.S to acheive
the same result as IA32?

Thanks

Mike

