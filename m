From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 11 Jul 2003 00:04:43 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105788202015446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Fri, 11 Jul 2003 09:22:42 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:
Peter> I'm not finding that clone2() works -- We get a segfault in the
Peter> cloned process when it returns.

Peter> __clone2(func, stack, STACKSIZE, SIGCHLD, NULL, NULL, NULL,
Peter> NULL))

David> Umh, you're creating a new process with a different initial
David> function.  I doubt this has ever been tested.  It probably
David> should work, but I don't know of any app doing this for real
David> (either you fork, or you create a thread).

The library __clone2() call should cope with this.
It does, essentially,

   switch(kidpid = sys_clone2(flags, stackbase, stacksize, ptidp, tlsp, tidp)) {
   case -1:
	goto __syscall_error;
   case 0:
	exit(fn(arg));
   default:
	return kidpid;
   }

Peter C
