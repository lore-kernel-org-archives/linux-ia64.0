From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 02 Feb 2012 11:19:41 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <20120202111941.GA7714@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb>
 <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
 <1328128874.15992.6430.camel@triegel.csb>
 <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
In-Reply-To: <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> [...]
> 
> And I realize that compiler people tend to think that loop 
> hoisting etc is absolutely critical for performance, and some 
> big hammer like "barrier()" makes a compiler person wince. You 
> think it results in horrible code generation problems.
> 
> It really doesn't. Loops are fairly unusual in the kernel to 
> begin with, and the compiler barriers are a total non-issue. 
> We have much more problems with the actual CPU barriers that 
> can be *very* expensive on some architectures, and we work a 
> lot at avoiding those and avoiding cacheline ping-pong issues 
> etc.

Just to underline this point, if barriers caused optimization 
problems when GCC builds the kernel then we'd expect to see 
various code generation problems: for example the compiler would 
not be able to cache things well enough and reorder it to make 
the code faster and (often) more compact.

So to test that effect of Linus's claim I picked up a fairly 
bleeding edge version of GCC:

  gcc version 4.7.0 20120112 (Red Hat 4.7.0-0.6) (GCC)

and performed a test build of the kernel with the majority of 
optimization barriers removed (using the v3.2 kernel, x86 
defconfig, 64-bit, -O2 optimization level): 1600 barriers were 
removed (!) and GCC's hands were thus freed to create more 
optimal code [and a very broken kernel], if it could.

I compared the resulting kernel image to an unmodified kernel 
image:

    text	   data	    bss	     dec	    hex	filename
 9781555	 982328	1118208	11882091	 b54e6b	vmlinux.vanilla
 9780972	 982328	1118208	11881508	 b54c24	vmlinux.no-barriers

So the barriers are costing us only a 0.06% size increase - 583 
bytes on an almost 10 MB kernel image.

To put that into perspectve: a *single* inline function inlining 
decision by the compiler has a larger effect than that. Just a 
couple of days ago we uninlined a function, which had an order 
of magnitude larger effect than this.

The other possible dimension would be the ordering of 
instructions.

To test for that effect I disassembled the two kernel images and 
performed a function by function, instruction by instruction 
comparison of instruction ordering. The summary is that GCC was 
able to remove only 86 instructions (0.005%) and reordered 
around 2400 instructions (0.15%) - out of about 1,570,000 
instructions.

Or, put differently, for the 1600 barriers in this particular 
kernel build, there's about 1.5 instructions reordered and 0.05 
instructions removed.

I also inspected the type of reordering: the overwhelming 
majority of reordering happened within a jump-free basic block 
of instructions and did not affect any loops.

Thus much of the effect of barriers kernel is only the crutial 
effect that we want them to have: to reorder code to have a 
specific program order sequence - but in the process the 
barriers() cause very, very small optimization quality side 
effects.

So the numbers support Linus's claim, the kernel incurs very 
little optimization cost side effects from barriers.
 
Thanks,

	Ingo
