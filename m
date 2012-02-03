From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 03 Feb 2012 17:16:43 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFx1NjR9XMQ9iLyVk05Erwtqgf7hfZkBCMJzkCMFJS8CHw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb> <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
 <1328128874.15992.6430.camel@triegel.csb> <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
 <20120201224554.GK2382@linux.vnet.ibm.com> <CA+55aFyzYO0CMZOgdrVV0PdG2DkbwTQG7eE7N3bp=0tQmruFEQ@mail.gmail.com>
 <20120202184209.GD2518@linux.vnet.ibm.com> <CA+55aFyYxzED4OoYvb3nbET7_zyP5mGhEa2w_QCvQOx55bVjHg@mail.gmail.com>
 <20120202193747.GG2518@linux.vnet.ibm.com> <4F2C0D8A.70103@redhat.com>
In-Reply-To: <4F2C0D8A.70103@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andrew MacLeod <amacleod@redhat.com>
Cc: paulmck@linux.vnet.ibm.com, Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Fri, Feb 3, 2012 at 8:38 AM, Andrew MacLeod <amacleod@redhat.com> wrote:
>
> The atomic intrinsics were created for c++11 =A0memory model compliance, =
but I
> am certainly open to enhancements that would make them more useful. =A0 I=
 am
> planning some enhancements for 4.8 now, and it sounds like you may have s=
ome
> suggestions...

So we have several atomics we use in the kernel, with the more common being

 - add (and subtract) and cmpchg of both 'int' and 'long'

 - add_return (add and return new value)

 - special cases of the above:
      dec_and_test (decrement and test result for zero)
      inc_and_test (decrement and test result for zero)
      add_negative (add and check if result is negative)

   The special cases are because older x86 cannot do the generic
"add_return" efficiently - it needs xadd - but can do atomic versions
that test the end result and give zero or sign information.

 - atomic_add_unless() - basically an optimized cmpxchg.

 - atomic bit array operations (bit set, clear, set-and-test,
clear-and-test). We do them on "unsigned long" exclusively, and in
fact we do them on arrays of unsigned long, ie we have the whole "bts
reg,mem" semantics. I'm not sure we really care about the atomic
versions for the arrays, so it's possible we only really care about a
single long.

   The only complication with the bit setting is that we have a
concept of "set/clear bit with memory barrier before or after the bit"
(for locking). We don't do the whole release/acquire thing, though.

 - compare_xchg_double

We also do byte/word atomic increments and decrements, but that' sin
the x86 spinlock implementation, so it's not a generic need.

We also do the add version in particular as CPU-local optimizations
that do not need to be SMP-safe, but do need to be interrupt-safe. On
x86, this is just an r-m-w op, on most other architectures it ends up
being the usual load-locked/store-conditional.

I think that's pretty much it, but maybe I'm missing something.

Of course, locking itself tends to be special cases of the above with
extra memory barriers, but it's usually hidden in asm for other
reasons (the bit-op + barrier being a special case).

                      Linus
