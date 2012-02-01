From: Jiri Kosina <jkosina@suse.cz>
Date: Wed, 01 Feb 2012 17:11:29 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <1328114266.5355.44.camel@lenny> <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com>
In-Reply-To: <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Colin Walters <walters@verbum.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, 1 Feb 2012, Linus Torvalds wrote:

> But the compiler turns the access to the bitfield (in a 32-bit aligned
> word) into a 64-bit access that accesses the word *next* to it.
> 
> That word next to it might *be* the lock, for example.
> 
> So we could literally have this kind of situation:
> 
>    struct {
>       atomic_t counter;
>       unsigned int val:4, other:4, data:24;
>    };
> 
> and if we write code like this:
> 
>     spin_lock(&somelock);
>     s->data++;
>     spin_unlock(&somelock);
> 
> and on another CPU we might do
> 
>    atomic_inc(&counter);
> 
> and the access to the bitfield will *corrupt* the atomic counter, even
> though both of them are perfectly fine!
> 
> Quite frankly, if the bug is simply because gcc doesn't actually know
> or care about the underlying size of the bitmask, it is possible that
> we can find a case where gcc clearly is buggy even according to the
> original C rules.
> 
> Honza - since you have access to the compiler in question, try
> compiling this trivial test-program:
> 
> 
>    struct example {
>       volatile int a;
>       int b:1;
>    };
> 
>    ..
>      s->b = 1;
>    ..
> 
> and if that bitfield access actually does a 64-bit access that also
> touches 's->a', then dammit, that's a clear violation of even the
> *old* C standard, and the gcc people cannot just wave away their bugs
> by saying "we've got standads, pttthththt".
> 
> And I suspect it really is a generic bug that can be shown even with
> the above trivial example.

I have actually tried exactly this earlier today (because while looking at 
this, I had an idea that putting volatile in place could be a workaround, 
causing gcc to generate a saner code), but it doesn't work either:

# cat x.c
struct x {
    long a;
    volatile unsigned int lock;
    unsigned int full:1;
};

void
wrong(struct x *ptr)
{
        ptr->full = 1;
}

int main()
{
        wrong(0);
}
# gcc -O2 x.c
# gdb -q ./a.out 
Reading symbols from /root/a.out...done.
(gdb) disassemble wrong
Dump of assembler code for function wrong:
   0x40000000000005c0 <+0>:     [MMI]       adds r32=8,r32
   0x40000000000005c1 <+1>:                 nop.m 0x0
   0x40000000000005c2 <+2>:                 mov r15=1;;
   0x40000000000005d0 <+16>:    [MMI]       ld8 r14=[r32];;
   0x40000000000005d1 <+17>:                nop.m 0x0
   0x40000000000005d2 <+18>:                dep r14=r15,r14,32,1;;
   0x40000000000005e0 <+32>:    [MIB]       st8 [r32]=r14
   0x40000000000005e1 <+33>:                nop.i 0x0
   0x40000000000005e2 <+34>:                br.ret.sptk.many b0;;

In my opinion, this is a clear bug in gcc (while the original problem, 
without explitict volatile, is not a C spec violation per se, it's just 
very inconvenient :) ).

-- 
Jiri Kosina
SUSE Labs
