From: Weihaw Chuang <weihaw@yahoo.com>
Date: Fri, 25 Jan 2002 09:28:25 +0000
Subject: [Linux-ia64] ptrace behavior accessing ar.lc and ar.ec
Message-Id: <marc-linux-ia64-105590698805929@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi folks,
I'm using the ptrace interface to create a
"architectural" processor state tracing tool.  When I
access AR.LC and AR.EC, I *usually* get the expected
result, but every once and a while it returns a bogus
result.

Is there a known bug, or am I using ptrace
incorrectly?

Here's how its used:
lc = ptrace (PTRACE_PEEKUSER, state->pid, PT_AR_LC,
0);

The tracing program observes some sort of behavior
like:

mov.i ar.lc = r61    (I'm pretty sure r61 is 6), and  
                       ptrace returns 0 
sxt4  r22=r60        ptrace returns -1
.....                "
(swp kernel code)    "
.....                "
br.ctop.sptk.few .b9 ptrace returns -1, br taken 
(p17) st8 [r15]=r34  ptrace returns 5

Many thanks,
-Wei


==************************************************************

Weihaw Chuang
wchuang@cs.ucsd.edu

************************************************************

__________________________________________________
Do You Yahoo!?
Great stuff seeking new owners in Yahoo! Auctions! 
http://auctions.yahoo.com

