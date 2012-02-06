From: Torvald Riegel <triegel@redhat.com>
Date: Mon, 06 Feb 2012 15:38:03 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <1328542683.13242.311.camel@triegel.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
	 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
	 <1328118174.15992.6206.camel@triegel.csb>
	 <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
	 <1328128874.15992.6430.camel@triegel.csb>
	 <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
	 <20120201224554.GK2382@linux.vnet.ibm.com>
	 <CA+55aFyzYO0CMZOgdrVV0PdG2DkbwTQG7eE7N3bp=0tQmruFEQ@mail.gmail.com>
	 <20120202184209.GD2518@linux.vnet.ibm.com>
	 <CA+55aFyYxzED4OoYvb3nbET7_zyP5mGhEa2w_QCvQOx55bVjHg@mail.gmail.com>
	 <20120202193747.GG2518@linux.vnet.ibm.com> <4F2C0D8A.70103@redhat.com>
	 <CA+55aFx1NjR9XMQ9iLyVk05Erwtqgf7hfZkBCMJzkCMFJS8CHw@mail.gmail.com>
	 <4F2C329B.2080107@redhat.com>
	 <CA+55aFxoW0zexd4Zy33gToK9V0UU6wbQFFogEyFPPiGuNq2GGQ@mail.gmail.com>
In-Reply-To: <CA+55aFxoW0zexd4Zy33gToK9V0UU6wbQFFogEyFPPiGuNq2GGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew MacLeod <amacleod@redhat.com>, paulmck@linux.vnet.ibm.com, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, GCC Patches <gcc@gcc.gnu.org>

On Fri, 2012-02-03 at 12:00 -0800, Linus Torvalds wrote:
> Of course, it you expose some intrinsic for the whole "ll/sc" model
> (and you then turn it into cmpxchg on demand), we could literally
> open-code it.
> 
> That is likely the most *flexible* approach for a compiler. I think
> pretty much everything the kernel needs (except for cmpxchg_double)
> can be very naturally written as a "ll/sc" sequence, and if the
> compiler then just does the right thing with peephole optimizations,
> that's fine.
> 
> IOW, we don't really need "atomic_add()" or anything like that. If we can do
> 
>   do {
>      val = __load_linked(mem);
>      val++;
>   } while (__store_conditional(val, mem));
> 
> and the compiler just automagically turns that into "lock add" on x86,
> that's perfectly fine.
> 
> It might not be too hard, because you really don't need to recognize
> very many patterns, and any pattern you don't recognize could be
> turned into a cmpxchg loop.
> 
> NOTE NOTE NOTE! The "turned into a cmpxchg loop" is not the true
> correct translation of load-linked/store-conditional, since it allows
> the memory to be modified as long as it's modified *back* before the
> store-conditional, and that actually matters for a few algorithms. But
> if you document the fact that it's not a "true" ll/sc (and maybe have
> some compile-time way to detect when it isn't), it would be very
> flexible.
> 
> Of course, the syntax could be something completely different. Maybe
> you'd want to do it as
> 
>    __builtin_ll_sc(&var, update-expression, return-expression,
> failure-expression)
> 
> rather than an explicit loop.
> 
> But it doesn't sound like the internal gcc model is based on some
> generic ll/sc model.

No, and I don't think it's beneficial overall to do this.  Sure, an
LL/SC or CAS loop is universal, but in turn programmers would have to
make sure that they hit the patterns that the compiler can actually
recognize and turn into the more efficient forms.

The custom atomic operations also provide different progress guarantees.
While a single CAS/cmpxchg is wait-free, the full loop isn't
necessarily.  Same for the bit operations.  So, I think it makes sense
to offer them separately.  The split between weak- and strong-progress
compare-and-exchange in C++11 is related.

> I realize that people have bad memories of the x86 bit instructions,
> but especially in their locked form, the fact that they take a few
> extra cycles or decode in only one pipeline etc is *not* relevant.
> They are small and "fast", because the true cost tends to be not the
> instruction cost, but the locking overhead and the cache effects.

And the semantics of the operation is known immediately (without trying
to recover the actual atomic op from some surrounding cmpxchg loop).
That allows potential optimizations like combining (but I'm not a HW
expert, so I don't know whether HW actually does this internally).


Torvald

