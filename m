From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 31 Dec 2003 09:34:15 +0000
Subject: ptrace() fix to make strace work better again
Message-Id: <16370.38935.531317.715179@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some of you have noticed that strace -f was often causing the target
process to crash.  The problem seems to be due to NPTL-enabled glibc
stressing ptrace() in different ways than LinuxThreads and as a
result, linking against NPTL triggered the strace problems.  The root
cause of the problem has been there for a long time (both in 2.4 and
2.6 kernels) it's just that we didn't see it before.

I have now a patch which fixes the strace -f problems without causing
any regressions in the gdb test-suite.  See this change-set:

  http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.1530

The changes are rather big, so I'd welcome thorough testing of it.  In
particular, it would be good to stress-test it more on largish
SMP-machines.  Also, if you have any apps that do strange things with
ptrace, or are using debuggers or strace a lot, please give it a good
whirl and let me know if you see any problems.

As for strace, with the patch I can now run "strace -f mozilla" without
any apparent problem.

Regards,

	--david
