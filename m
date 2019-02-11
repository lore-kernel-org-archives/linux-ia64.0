From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 11 Feb 2019 17:04:47 +0000
Subject: Re: [PATCH] locking/rwsem: Remove arch specific rwsem files
Message-Id: <20190211170447.GO32477@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549850450-10171-1-git-send-email-longman@redhat.com>
 <20190211115833.GY32511@hirez.programming.kicks-ass.net>
 <e470384d-fb7b-132d-253b-23c495e7c285@redhat.com>
In-Reply-To: <e470384d-fb7b-132d-253b-23c495e7c285@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-xtensa@linux-xtensa.org, Davidlohr Bueso <dave@stgolabs.net>, linux-ia64@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Mon, Feb 11, 2019 at 11:35:24AM -0500, Waiman Long wrote:
> On 02/11/2019 06:58 AM, Peter Zijlstra wrote:
> > Which is clearly worse. Now we can write that as:
> >
> >   int __down_read_trylock2(unsigned long *l)
> >   {
> > 	  long tmp = READ_ONCE(*l);
> >
> > 	  while (tmp >= 0) {
> > 		  if (try_cmpxchg(l, &tmp, tmp + 1))
> > 			  return 1;
> > 	  }
> >
> > 	  return 0;
> >   }
> >
> > which generates:
> >
> >   0000000000000030 <__down_read_trylock2>:
> >   30:   48 8b 07                mov    (%rdi),%rax
> >   33:   48 85 c0                test   %rax,%rax
> >   36:   78 18                   js     50 <__down_read_trylock2+0x20>
> >   38:   48 8d 50 01             lea    0x1(%rax),%rdx
> >   3c:   f0 48 0f b1 17          lock cmpxchg %rdx,(%rdi)
> >   41:   75 f0                   jne    33 <__down_read_trylock2+0x3>
> >   43:   b8 01 00 00 00          mov    $0x1,%eax
> >   48:   c3                      retq
> >   49:   0f 1f 80 00 00 00 00    nopl   0x0(%rax)
> >   50:   31 c0                   xor    %eax,%eax
> >   52:   c3                      retq
> >
> > Which is a lot better; but not quite there yet.
> >
> >
> > I've tried quite a bit, but I can't seem to get GCC to generate the:
> >
> > 	add $1,%rdx
> > 	jle
> >
> > required; stuff like:
> >
> > 	new = old + 1;
> > 	if (new <= 0)
> >
> > generates:
> >
> > 	lea 0x1(%rax),%rdx
> > 	test %rdx, %rdx
> > 	jle
> 
> Thanks for the suggested code snippet. So you want to replace "lea
> 0x1(%rax), %rdx" by "add $1,%rdx"?
> 
> I think the compiler is doing that so as to use the address generation
> unit for addition instead of using the ALU. That will leave the ALU
> available for doing other arithmetic operation in parallel. I don't
> think it is a good idea to override the compiler and force it to use
> ALU. So I am not going to try doing that. It is only 1 or 2 more of
> codes anyway.

Yeah, I was trying to see what I could make it do.. #2 really should be
good enough, but you know how it is once you're poking at it :-)
