From: Chandra Kapate <cs_kapate@yahoo.com>
Date: Fri, 04 Apr 2003 17:50:16 +0000
Subject: [Linux-ia64] A clarification about sys32_execve/ia32_execve
Message-Id: <marc-linux-ia64-105590723705421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I was looking at how execve syscalls work wrt to 32/64
syscalls. I have a basic question. I appreciate if
some once can clarify. I apologize if I am overlooking
some thing very obvious.

The ia32_execve (in ia32_entry.S) sets up out0, out1,
out2 and out3 before invoking sys32_execve. The out3
is setup for regs. But, in sys32_execve, the regs
is set locally using 9th parameters. I can see how
the regs is set using 9th parameter. I don't 
understand  why is set again in sys32_execve
when it is already set in out3 in ia32_execve and 
could have used as 4th parameter? Does args mis-match 
between ia32_execve and sys32_execve matter? 
OTH, sys_execve does use the regs set in ia64_execve.
Sorry, if i am overlooking something.

Thanks,
Chandra

__________________________________________________
Do you Yahoo!?
Yahoo! Tax Center - File online, calculators, forms, and more
http://tax.yahoo.com

