From: Kevin Buettner <kev@primenet.com>
Date: Tue, 09 Jan 2001 21:25:14 +0000
Subject: Re: [Linux-ia64] IA-64 Linux TODO list
Message-Id: <marc-linux-ia64-105590678205900@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205896@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Jan 9, 12:47pm, Don Dugger wrote:

> I'm willing to take on the taks of maintaining this list.  For now
> I'll put David's name next to the `kernel unaligned handler' and
> I'm willing to look into the `strace' issues.  If anyone else is
> willing to take on anything let me know and I'll add your name.
> I think it would be a good idea to have a responsible person for
> each item if possible.

Put me down for gdb.

> >  - gdb
> >     - NaT bits don't seem to work properly?
> >     - coredump support still broken?

I have a couple of other items to add to this list of things which
isn't working in gdb.

1) Calling inferior functions no longer works.  (At least it didn't in
   the recent Red Hat release.  I'm rebuilding gdb now with the
   TurboLinux release to check it there.) I've done some investigation
   of this problem and it looks to me like the RSE backing store is
   changing under us (gdb that is) when bsp is changed.

2) Hardware watchpoints no longer work.  Again, the value returned
   by the kernel looks suspect.  There appear to be a couple of bits
   that were reset...

In general, the state of gdb isn't as good right now as it used to
be.  There was a time when I was seeing only between 20-30 test
suite failures.  The number is now over 700.

Kevin

