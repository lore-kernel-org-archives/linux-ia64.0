From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 23:11:00 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFyzYO0CMZOgdrVV0PdG2DkbwTQG7eE7N3bp=0tQmruFEQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb> <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
 <1328128874.15992.6430.camel@triegel.csb> <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
 <20120201224554.GK2382@linux.vnet.ibm.com>
In-Reply-To: <20120201224554.GK2382@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulmck@linux.vnet.ibm.com
Cc: Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 2:45 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> My (perhaps forlorn and naive) hope is that C++11 memory_order_relaxed
> will eventually allow ACCESS_ONCE() to be upgraded so that (for example)
> access-once increments can generate a single increment-memory instruction
> on x86.

I don't think that is a semantic issue.

gcc could do it *today* with volatile accesses. It doesn't, because
volatiles are scary and basically disables a lot of optimizations. Why
would memory ordering be substantially different just because it has a
different name?

> New architectures might eventually might define things like atomic_inc()
> in terms of C++11 atomics, but let's start with the straightforward stuff
> as and if it makes sense.

SMP-atomic or percpu atomic? Or both?

We need both variants in the kernel. If the compiler generates one of
them for us, that doesn't really much help.

                          Linus
