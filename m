From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 03 Feb 2012 20:00:03 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFxoW0zexd4Zy33gToK9V0UU6wbQFFogEyFPPiGuNq2GGQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb> <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
 <1328128874.15992.6430.camel@triegel.csb> <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
 <20120201224554.GK2382@linux.vnet.ibm.com> <CA+55aFyzYO0CMZOgdrVV0PdG2DkbwTQG7eE7N3bp=0tQmruFEQ@mail.gmail.com>
 <20120202184209.GD2518@linux.vnet.ibm.com> <CA+55aFyYxzED4OoYvb3nbET7_zyP5mGhEa2w_QCvQOx55bVjHg@mail.gmail.com>
 <20120202193747.GG2518@linux.vnet.ibm.com> <4F2C0D8A.70103@redhat.com>
 <CA+55aFx1NjR9XMQ9iLyVk05Erwtqgf7hfZkBCMJzkCMFJS8CHw@mail.gmail.com> <4F2C329B.2080107@redhat.com>
In-Reply-To: <4F2C329B.2080107@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andrew MacLeod <amacleod@redhat.com>
Cc: paulmck@linux.vnet.ibm.com, Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Fri, Feb 3, 2012 at 11:16 AM, Andrew MacLeod <amacleod@redhat.com> wrote:
>> =A0 =A0The special cases are because older x86 cannot do the generic
>> "add_return" efficiently - it needs xadd - but can do atomic versions
>> that test the end result and give zero or sign information.
>
> Since these are older x86 only, could you use add_return() always and then
> have the compiler use new peephole optimizations to detect those usage
> patterns and change the instruction sequence for x86 when required? =A0wo=
uld
> that be acceptable? =A0 =A0Or maybe you don't trust the compiler :-) =A0 =
Or maybe
> I can innocently ask if the performance impact on older x86 matters enough
> any more? :-)

Since xadd is often slow even when it does exist, the peepholes would
definitely be required. A "dec_and_test" does need to be

   decl %m (or "subl $1" for x86-64)
   je

rather than

   xadd %r,%m
   cmp $1,%r
   je

simply because the latter is not just larger, but often quite a bit
slower (newer CPU's seem to be better at xadd).

But with the peepholes, by the time we could depend on gcc doing the
intrinsics, we'd almost certainly be ready to let the old pre-xadd
machines just go.

We're already almost there, and by the time we can trust the compiler
to do it for us, we're almost certainly going to be at a point where
we really don't care any more about pre-xadd (but we will still care
about older machines where xadd is slow).

>> =A0- atomic_add_unless() - basically an optimized cmpxchg.
>
> is this the reverse of a compare_exchange and add? =A0Ie, add if the value
> ISN'T expected? =A0 or some form of compare_exchange_and_add? =A0 =A0This=
 might
> require a new atomic builltin.
>
> What exactly does it do?

It's basically

   do {
     load-link %r,%m
     if (r =3D value)
         return 0;
     add
   } while (store-conditional %r,%m)
   return 1;

and it is used to implement two *very* common (and critical)
reference-counting use cases:

 - decrement ref-count locklessly, and if it hits free, take a lock
atomically (ie "it would be a bug for anybody to ever see it decrement
to zero while holding the lock")

 - increment ref-count locklessly, but if we race with the final free,
don't touch it, because it's gone (ie "if somebody decremented it to
zero while holding the lock, we absolutely cannot increment it again")

They may sound odd, but those two operations are absolutely critical
for most lock-less refcount management. And taking locks for reference
counting is absolutely death to performance, and is often impossible
anyway (the lock may be a local lock that is *inside* the structure
that is being reference-counted, so if the refcount is zero, then you
cannot even look at the lock!)

In the above example, the load-locked -> store-conditional would
obviously be a cmpxchg loop instead on architectures that do cmpxchg
instead of ll/sc.

Of course, it you expose some intrinsic for the whole "ll/sc" model
(and you then turn it into cmpxchg on demand), we could literally
open-code it.

That is likely the most *flexible* approach for a compiler. I think
pretty much everything the kernel needs (except for cmpxchg_double)
can be very naturally written as a "ll/sc" sequence, and if the
compiler then just does the right thing with peephole optimizations,
that's fine.

IOW, we don't really need "atomic_add()" or anything like that. If we can do

  do {
     val =3D __load_linked(mem);
     val++;
  } while (__store_conditional(val, mem));

and the compiler just automagically turns that into "lock add" on x86,
that's perfectly fine.

It might not be too hard, because you really don't need to recognize
very many patterns, and any pattern you don't recognize could be
turned into a cmpxchg loop.

NOTE NOTE NOTE! The "turned into a cmpxchg loop" is not the true
correct translation of load-linked/store-conditional, since it allows
the memory to be modified as long as it's modified *back* before the
store-conditional, and that actually matters for a few algorithms. But
if you document the fact that it's not a "true" ll/sc (and maybe have
some compile-time way to detect when it isn't), it would be very
flexible.

Of course, the syntax could be something completely different. Maybe
you'd want to do it as

   __builtin_ll_sc(&var, update-expression, return-expression,
failure-expression)

rather than an explicit loop.

But it doesn't sound like the internal gcc model is based on some
generic ll/sc model.

>> =A0- atomic bit array operations (bit set, clear, set-and-test,
>> clear-and-test). We do them on "unsigned long" exclusively, and in
>> fact we do them on arrays of unsigned long, ie we have the whole "bts
>> reg,mem" semantics. I'm not sure we really care about the atomic
>> versions for the arrays, so it's possible we only really care about a
>> single long.
>>
>> =A0 =A0The only complication with the bit setting is that we have a
>> concept of "set/clear bit with memory barrier before or after the bit"
>> (for locking). We don't do the whole release/acquire thing, though.
>
> Are these functions wrappers to a =A0tight load, mask, cmpxchg loop? or
> something else? =A0These could also require new built-ins if they can't be
> constructed from the existing operations...

Not usually, no. Those things tend to be used for locking or setting
state, so we'd commonly want them to result in

   lock orl $128,(%mem)

or for the testing case they would become

   lock btsl $0,(%mem)
   jne .. failed ..

and a cmpxchg loop would generally be much too expensive.

I realize that people have bad memories of the x86 bit instructions,
but especially in their locked form, the fact that they take a few
extra cycles or decode in only one pipeline etc is *not* relevant.
They are small and "fast", because the true cost tends to be not the
instruction cost, but the locking overhead and the cache effects.

And a "cmpxchg" loop tends to be *very* expensive for two reasons:

 - mispredicted backwards jump (most cpu's think it's a loop, so
without prediction information they do the wrong thing)

 - load+cmpxchg does the wrong thing for a cache miss (the load will
result in the cacheline being fetched for read)

both of which tend to be totally invisible if you do the obvious
microbenchmark, making people sometimes mistakenly believe that
"cmpxchg" is a good way to implement things.

>> =A0- compare_xchg_double
>>
>> We also do byte/word atomic increments and decrements, but that' sin
>> the x86 spinlock implementation, so it's not a generic need.
>
> The existing __atomic builtins will work on 1,2,4,8 or 16 byte values
> regardless of type, as long as the hardware supports those sizes. =A0so x=
86-64
> can do a 16 byte cmpxchg.

Ok.

> In theory, the add_fetch and sub_fetch are suppose to use INC/DEC if the
> operand is 1/-1 and the result isn't used. =A0If it isnt doing this right=
 now,
> I will fix it.

Yeah, we definitely want that fixed to inc/dec or regular add/sub.
xadd really isn't good, even outside the "some CPU's don't support
it".

> It may be possible to add modifier extensions to the memory model compone=
nt
> for such a thing. ie
>
> v =3D __atomic_add_fetch (&v, __ATOMIC_RELAXED | __ATOMIC_CPU_LOCAL)

Ok, that sounds clean.

> All of the __atomic operations are currently optimization barriers in both
> directions, the optimizers tend to treat them like function calls. =A0I h=
ope
> to enable some sorts of optimizations eventually, especially based on mem=
ory
> model... but for now we play it safe.

That's fine. I really don't worry about compiler barriers, and the use
of __ATOMIC_ACQUIRE and __ATOMIC_RELEASE will actually allow us to do
better than we do now, if the compiler just implements them correctly
on all architectures.

Right now we have special (and very ugly) extra conditional
architecture-specific full memory barriers ("smp_mb__after_bitop()"
etc) that are complete hacks, but generate "good enough" code (which
on x86 means "generate nothing", since the atomic bitops are already
barriers on their own).

Having access to __ATOMIC_ACQUIRE would actually be an improvement -
it's just that the architectures that really care about things like
that simply don't matter enough for us to really worry about them
(ia64 being the prime example), and everybody else either doesn't need
extra barriers at all (x86), or might as well use a full barrier (most
everything else).

                    Linus
