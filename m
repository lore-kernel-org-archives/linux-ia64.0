From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jul 2003 23:31:14 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105787991313681@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 11 Jul 2003 09:22:42 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> I'm not finding that clone2() works -- We get a segfault in the cloned
  Peter> process when it returns.

  Peter> __clone2(func, stack, STACKSIZE, SIGCHLD, NULL, NULL,  NULL, NULL))

Umh, you're creating a new process with a different initial function.
I doubt this has ever been tested.  It probably should work, but I
don't know of any app doing this for real (either you fork, or you
create a thread).

	--david
