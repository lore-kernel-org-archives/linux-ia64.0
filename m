From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 25 Jan 2002 16:30:10 +0000
Subject: Re: [Linux-ia64] ptrace behavior accessing ar.lc and ar.ec
Message-Id: <marc-linux-ia64-105590698805932@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805929@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805929@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 > Hi folks,
 > I'm using the ptrace interface to create a
 > "architectural" processor state tracing tool.  When I
 > access AR.LC and AR.EC, I *usually* get the expected
 > result, but every once and a while it returns a bogus
 > result.

 > Is there a known bug, or am I using ptrace
 > incorrectly?

Not a known bug.

 > Here's how its used:
 > lc = ptrace (PTRACE_PEEKUSER, state->pid, PT_AR_LC,
 > 0);

 > The tracing program observes some sort of behavior
 > like:

 > mov.i ar.lc = r61    (I'm pretty sure r61 is 6), and  
 >                        ptrace returns 0 
 > sxt4  r22=r60        ptrace returns -1
 > .....                "
 > (swp kernel code)    "
 > .....                "
 > br.ctop.sptk.few .b9 ptrace returns -1, br taken 
 > (p17) st8 [r15]=r34  ptrace returns 5

Do you have a self-contained and small test program that reproduces
the problem?  That would make it easier to investigate the problem.

	--david

