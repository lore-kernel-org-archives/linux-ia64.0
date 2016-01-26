From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 26 Jan 2016 23:45:23 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <CA+55aFyD94yaA1QzXgfeO18T-czY3TVUi5n6r-9jOUObDeR-zQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114204827.GE3818@linux.vnet.ibm.com>
	<20160118081929.GA30420@gondor.apana.org.au>
	<20160118154629.GB3818@linux.vnet.ibm.com>
	<20160126165207.GB6029@fixme-laptop.cn.ibm.com>
	<20160126172227.GG6357@twins.programming.kicks-ass.net>
	<CA+55aFzcC6C8imPs5vk4yH1Y2YHjnAdFM9HCkVs04COxuDQH6w@mail.gmail.com>
	<20160126201037.GU4503@linux.vnet.ibm.com>
	<CA+55aFxjb+2rs2wVHtiSCcOzgMrE8H=yDeNcjyujPQudDCtLgw@mail.gmail.com>
	<CA+55aFwxTJd+uibcxtZD3tGnj_n=LMwyAa0s8qyx_OF0OMWQkA@mail.gmail.com>
	<20160126232921.GY4503@linux.vnet.ibm.com>
In-Reply-To: <20160126232921.GY4503@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, linux-mips <linux-mips@linux-mips.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, Will Deacon <will.deacon@arm.com>, virtualization <virtualization@lists.linux-foundation.org>, Peter Anvin <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, uml-devel <user-mode-linux-devel@lists.sourceforge.net>, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, the arch/x86 maintainers <x86@kernel.org>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@li

On Tue, Jan 26, 2016 at 3:29 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> No trailing data-dependent read, so agreed, no smp_read_barrier_depends()
> needed.  That said, I believe that we should encourage rcu_dereference*()
> or lockless_dereference() instead of READ_ONCE() for documentation
> reasons, though.

I agree that that is likely the right thing to do in pretty much all situations.

In theory, there might be performance situations where we'd want to
actively avoid the smp_read_barrier_depends() inherent in those, but
considering that it's only a performance issue on alpha, and we
probably have all of two or three people using Linux on alpha, it's a
pretty theoretical performance worry.

                  Linus
