From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 May 2004 20:23:46 +0000
Subject: Re: Kill warnings in 2.6.6
Message-Id: <16558.25938.462552.233122@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 > -#define cond_syscall(x) asmlinkage long x() __attribute__((weak,alias("sys_ni_syscall")));
 > +#define cond_syscall(x) asmlinkage long x(void) __attribute__((weak,alias("sys_ni_syscall")));

I made this change now.  The Intel compiler certainly compiles it fine
and it gets rid of the last remaining large blob of annoying warning
messages in sys.c.  I didn't try building the entire kernel with the
Intel compiler, but in the unlikely event that Peter's version leads
to link-time-problems, we can fix that later, when Intel makes the
script available needed to compile the kernel (hint, hint... ;-).

	--david
