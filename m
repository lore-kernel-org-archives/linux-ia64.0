From: Nathan Straz <nstraz@sgi.com>
Date: Wed, 09 Jul 2003 21:32:59 +0000
Subject: clone testcases in LTP
Message-Id: <marc-linux-ia64-105778639326638@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Could someone in the Linux ia64 community look at the clone system call
tests that the LTP has under ltp/testcases/kernel/syscalls/clone?  I
know that ia64 uses clone2() instead of clone() but I don't know where
the differences are documented.  I would like to get these test cases,
or some variation or them, compiling and running on ia64.

Thanks,
-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                                  http://ltp.sf.net/
