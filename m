From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 03 Jul 2003 02:02:54 +0000
Subject: copy_thread preserves kernel stack
Message-Id: <marc-linux-ia64-105719797219701@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 version of copy_thread() preserves the parent kernel stack
which takes stack space away from the child thread, increasing the risk
of stack overflow.  The i386 version of copy_thread() creates a
pristine stack for the new thread.

ia64 has a comment "Note: if we get called through kernel_thread() then
the memory above "(highest addr)" is valid kernel stack memory that
needs to be copied as well".  i386 kernel threads work fine without the
extra stack wastage, so there is no generic reason to save the parent
backtrace.  Apart from unwind problems, I can see no reason for ia64 to
preserve the parent's task in kernel threads.  Any objections to me
doing a patch that constructs an empty stack for ia64 kernel threads?


