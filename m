From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 26 Sep 2001 22:24:24 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805256@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Sep 2001 21:35:12 +0200 (CEST), stefan <stefan@lkcc.org> said:

  Stefan> Hello list, I wonder if the above function set can be used
  Stefan> to implement something like what is used to work on other
  Stefan> types of machines with setjmp()/longjmp(). I would like to
  Stefan> continue a program at a certain point of execution with a
  Stefan> saved environment.

From this description, it sounds like you'd want to use swapcontext().
I don't quite understand your pseudo-code though (what's are
save_both_stacks()/restore_both_stacks() supposed to do?).

I do agree though that it would be nice to have a portable and
thread-safe way of determining whether or not a getcontext() is
returning for the first time.  On ia64, I made getcontext() return
this information in register r9, but that's obviously not a portable
solution.

	--david

