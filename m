From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 06:58:20 +0000
Subject: Re: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized
Message-Id: <16576.7564.224810.542608@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 03 Jun 2004 23:12:49 -0700, Ulrich Drepper <drepper@redhat.com> said:

  Uli> David Mosberger wrote:

  >> Does anyone else find it annoying that gettimeofday() only provides
  >> micro-second resolution?  We can do syscalls significantly faster than
  >> that (especially with a light-weight syscall handler).  Time for a
  >> kernel extension?

  Uli> What do you think clock_gettime(CLOCK_REALTIME) is for?

clock_gettime() is fine.  I think last time I played with it it was
still implemented in user-level.  Probably just a matter of an "old"
libc...

	--david
