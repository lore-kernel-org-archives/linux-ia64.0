From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 15 Oct 2001 18:19:57 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805345@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 11 Oct 2001 13:33:49 +0200 (CEST), stefan <stefan@lkcc.org> said:

  Stefan> I found some ia64 machine which declares `mcontext_t' in
  Stefan> <sys/ucontext.h> in another way as `sigcontext' in
  Stefan> <bits/sigcontext.h>. That is dated on May 22nd this
  Stefan> year. With members like `ar_bsp_base' and `ar_bspstore'...
  Stefan> That is why I ask.

Oh, right.  I had forgotten about that.  Any version of glibc that
comes with setcontext()/getcontext() should have a correct ucontext.h,
but we didn't implement those routines until quite late in the game.
If I recall correctly, they were first supported by glibc-2.2.3, but
there were some nasty bugs, so I think you pretty much have to use
glibc-2.2.4 or newer.

	--david

