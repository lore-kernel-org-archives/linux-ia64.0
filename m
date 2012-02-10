From: Richard Henderson <rth@redhat.com>
Date: Fri, 10 Feb 2012 19:27:34 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <4F356FA6.4000104@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com> <1328118174.15992.6206.camel@triegel.csb> <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com> <1328128874.15992.6430.camel@triegel.csb> <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com> <20120201224554.GK2382@linux.vnet.ibm.com> <CA+55aFyzYO0CMZOgdrVV0PdG2DkbwTQG7eE7N3bp=0tQmruFEQ@mail.gmail.com> <20120202184209.GD2518@linux.vnet.ibm.com> <CA+55aFyYxzED4OoYvb3nbET7_zyP5mGhEa2w_QCvQOx55bVjHg@mail.gmail.com> <20120202193747.GG2518@linux.vnet.ibm.com> <4F2C0D8A.70103@redhat.com> <CA+55aFx1NjR9XMQ9iLyVk05Erwtqgf7hfZkBCMJzkCMFJS8CHw@mail.gmail.com> <4F2C329B.2080107@redhat.com> <CA+55aFxoW0zexd4Zy33gToK9V0UU6wbQFFogEyFPPiGuNq2GGQ@mail.gmail.com>
In-Reply-To: <CA+55aFxoW0zexd4Zy33gToK9V0UU6wbQFFogEyFPPiGuNq2GGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew MacLeod <amacleod@redhat.com>, paulmck@linux.vnet.ibm.com, Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On 02/03/2012 12:00 PM, Linus Torvalds wrote:
>    do {
>      load-link %r,%m
>      if (r = value)
>          return 0;
>      add
>    } while (store-conditional %r,%m)
>    return 1;
> 
> and it is used to implement two *very* common (and critical)
> reference-counting use cases:
> 
>  - decrement ref-count locklessly, and if it hits free, take a lock
> atomically (ie "it would be a bug for anybody to ever see it decrement
> to zero while holding the lock")
> 
>  - increment ref-count locklessly, but if we race with the final free,
> don't touch it, because it's gone (ie "if somebody decremented it to
> zero while holding the lock, we absolutely cannot increment it again")
> 
> They may sound odd, but those two operations are absolutely critical
> for most lock-less refcount management. And taking locks for reference
> counting is absolutely death to performance, and is often impossible
> anyway (the lock may be a local lock that is *inside* the structure
> that is being reference-counted, so if the refcount is zero, then you
> cannot even look at the lock!)
> 
> In the above example, the load-locked -> store-conditional would
> obviously be a cmpxchg loop instead on architectures that do cmpxchg
> instead of ll/sc.
> 
> Of course, it you expose some intrinsic for the whole "ll/sc" model
> (and you then turn it into cmpxchg on demand), we could literally
> open-code it.

We can't expose the ll/sc model directly, due to various target-specific
hardware constraints (e.g. no other memory references, i.e. no spills).
But the "weak" compare-exchange is sorta-kinda close.

A "weak" compare-exchange is a ll/sc pair, without the loop for restart
on sc failure.  Thus a weak compare-exchange can fail for arbitrary reasons.
You do, however, get back the current value in the memory, so you can loop
back yourself and try again.

So that loop above becomes the familiar expression as for CAS:

  r = *m;
  do {
    if (r = value)
      return;
    n = r + inc;
  } while (!atomic_compare_exchange(m, &r, n, /*weak=*/true,
				    __ATOMIC_RELAXED, __ATOMIC_RELAXED));

which, unlike with the current __sync_val_compare_and_swap, does not
result in a nested loop for the ll/sc architectures.

Yes, the ll/sc architectures can technically do slightly better by writing
this as inline asm, but the gain is significantly less than before.  Given
that the line must be in L1 cache already, the redundant load from M in
the ll insn should be nearly negligible.

Of course for architectures that implement cas, there is no difference
between "weak" and "strong".


r~
