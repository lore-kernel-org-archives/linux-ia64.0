From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Apr 2003 00:14:23 +0000
Subject: Re: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705435@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 07 Apr 2003 19:13:40 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> This is the situation I was trying to fix, adding a wmb() to
  Jes> spin_unlock() seems the only way to get around it as far as I can see.
  Jes> I take it you agree then?

As Jim pointed out, there is an anologous problem on the read-side.
Declaring the pointer "volatile" fixes the problem for ia64 and is
arguably the right (logical) thing to do anyhow.

However, it won't fix the problem for Alpha though: there you'd need
to add rmb() between the two reads on cpu2() (read_barrier_depends()
only guarantees ordering for data-dependent reads, so it won't work
here).

So, the most portable way to fix this is to add a wmb() on the side of
cpu1() and rmb() on the read side.

	--david

