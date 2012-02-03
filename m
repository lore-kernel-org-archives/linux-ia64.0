From: Andrew MacLeod <amacleod@redhat.com>
Date: Fri, 03 Feb 2012 19:16:43 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <4F2C329B.2080107@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com> <1328118174.15992.6206.camel@triegel.csb> <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com> <1328128874.15992.6430.camel@triegel.csb> <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com> <20120201224554.GK2382@linux.vnet.ibm.com> <CA+55aFyzYO0CMZOgdrVV0PdG2DkbwTQG7eE7N3bp=0tQmruFEQ@mail.gmail.com> <20120202184209.GD2518@linux.vnet.ibm.com> <CA+55aFyYxzED4OoYvb3nbET7_zyP5mGhEa2w_QCvQOx55bVjHg@mail.gmail.com> <20120202193747.GG2518@linux.vnet.ibm.com> <4F2C0D8A.70103@redhat.com> <CA+55aFx1NjR9XMQ9iLyVk05Erwtqgf7hfZkBCMJzkCMFJS8CHw@mail.gmail.com>
In-Reply-To: <CA+55aFx1NjR9XMQ9iLyVk05Erwtqgf7hfZkBCMJzkCMFJS8CHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: paulmck@linux.vnet.ibm.com, Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On 02/03/2012 12:16 PM, Linus Torvalds wrote:
>
> So we have several atomics we use in the kernel, with the more common being
>
>   - add (and subtract) and cmpchg of both 'int' and 'long'
This would be __atomic_fetch_add, __atomic_fetch_sub, and 
__atomic_compare_exchange.

For 4.8 __atomic_compare_exchange is planned to be better optimized then 
it is now...  ie, it currently uses the same form as c++ requires:

  atomic_compare_exchange (&var, &expected, value, weak/strong, 
memorymodel).

'expected' is updated in place with the current value if it doesn't 
match.  With the address of expected taken, we dont always do a good job 
generating code for it... I plan to remedy that in 4.8 so that it is 
efficient and doesn't impact optimization of 'expected' elsewhere.
>   - add_return (add and return new value)
__atomic_add_fetch returns the new value. (__atomic_fetch_add returns 
the old value).   If it isn't as efficient as it needs to be, the RTL 
pattern can be fixed.    what sequence do you currently use for this?  
The compiler currently generates the equivilent of

lock; xadd
add

ie, it performs the atomic add then re-adds the same value to the 
previous value to get the atomic post-add value.  If there is something 
more efficient, we ought to be able to do the same.
>   - special cases of the above:
>        dec_and_test (decrement and test result for zero)
>        inc_and_test (decrement and test result for zero)
>        add_negative (add and check if result is negative)
>
>     The special cases are because older x86 cannot do the generic
> "add_return" efficiently - it needs xadd - but can do atomic versions
> that test the end result and give zero or sign information.
Since these are older x86 only, could you use add_return() always and 
then have the compiler use new peephole optimizations to detect those 
usage patterns and change the instruction sequence for x86 when 
required?  would that be acceptable?    Or maybe you don't trust the 
compiler :-)   Or maybe I can innocently ask if the performance impact 
on older x86 matters enough any more? :-)
>   - atomic_add_unless() - basically an optimized cmpxchg.

is this the reverse of a compare_exchange and add?  Ie, add if the value 
ISN'T expected?   or some form of compare_exchange_and_add?    This 
might require a new atomic builltin.

What exactly does it do?

>   - atomic bit array operations (bit set, clear, set-and-test,
> clear-and-test). We do them on "unsigned long" exclusively, and in
> fact we do them on arrays of unsigned long, ie we have the whole "bts
> reg,mem" semantics. I'm not sure we really care about the atomic
> versions for the arrays, so it's possible we only really care about a
> single long.
>
>     The only complication with the bit setting is that we have a
> concept of "set/clear bit with memory barrier before or after the bit"
> (for locking). We don't do the whole release/acquire thing, though.
Are these functions wrappers to a  tight load, mask, cmpxchg loop? or 
something else?  These could also require new built-ins if they can't be 
constructed from the existing operations...
>
>   - compare_xchg_double
>
> We also do byte/word atomic increments and decrements, but that' sin
> the x86 spinlock implementation, so it's not a generic need.
The existing __atomic builtins will work on 1,2,4,8 or 16 byte values 
regardless of type, as long as the hardware supports those sizes.  so 
x86-64 can do a 16 byte cmpxchg.

In theory, the add_fetch and sub_fetch are suppose to use INC/DEC if the 
operand is 1/-1 and the result isn't used.  If it isnt doing this right 
now, I will fix it.
> We also do the add version in particular as CPU-local optimizations
> that do not need to be SMP-safe, but do need to be interrupt-safe. On
> x86, this is just an r-m-w op, on most other architectures it ends up
> being the usual load-locked/store-conditional.
>
It may be possible to add modifier extensions to the memory model 
component for such a thing. ie

v = __atomic_add_fetch (&v, __ATOMIC_RELAXED | __ATOMIC_CPU_LOCAL)

which will allow fine tuning for something more specific like this. 
Targets which dont care can ignore it, but x86 could have atomic_add  
avoid the lock when the CPU_LOCAL modifier flag is present.

> I think that's pretty much it, but maybe I'm missing something.
>
> Of course, locking itself tends to be special cases of the above with
> extra memory barriers, but it's usually hidden in asm for other
> reasons (the bit-op + barrier being a special case).

All of the __atomic operations are currently optimization barriers in 
both directions, the optimizers tend to treat them like function calls.  
I hope to enable some sorts of optimizations eventually, especially 
based on memory model... but for now we play it safe.

Synchronization barriers are inserted based on the memory model used.  
If it can be determined that something additional is required that the 
existing memory model doesn't cover, it could be possible to add 
extensions beyond the c++11 memory model.. ( ie add new 
__ATOMIC_OTHER_BARRIER_KIND models)

Andrew

