From: Rich Altmaier <richa@cthulhu.engr.sgi.com>
Date: Wed, 23 Feb 2000 00:47:35 +0000
Subject: Re: [Linux-ia64] ILP32 support?
Message-Id: <marc-linux-ia64-105590678204962@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I would like to express real concern with this proposal.  We went down this
path with IRIX on the MIPS processor.  
The situation is:  We are asking ISVs to generate native IA64 binaries.  
If there are two formats of such
binaries, and they are not link compatible, now any ISV failing to release
both formats will cause a terrible fragmentation.  Any given user will not
be sure of being able to find link compatible stuff for their needs.  This
is a terrible inhibitor to the spread of software, not to mention creating
dual libraries for all IA64 stuff (ok guys, where are you going to put these
new libs?  This is a new ABI you understand!!!).

But perhaps you were not suggesting this.  I believe Microsoft has defined
a special form of native 64bit-address IA64 code, called "the sandbox", where
the linker and kernel simply assign all addresses below say 2Gbyte.  This
code still contains 64bit pointer types, but it has no actual values exceeding
32bit container.  Hence sloppy code converting pointers to say ints doesn't
lose bits.  But the pointer data type still changes size to 64bits, hence porting
is not 0 effort.  I'm not clear on the linkage compatibility issues here.

I would implore you to not issue such buggy code.   Please make your code
64bit-address clean.  Please don't split the IA64 marketplace!!!!!!!!!

Thanks, Rich


Vadim Furman wrote:
> 
> >
> >   Vadim> Are there any plans to support ILP32 mode?  Vadim Furman
> >
> > No.  So far, nobody has felt that the (small) benefits of ILP32 are
> > worth its trouble.
> IMHO benefits of ILP32 are huge, since you can relatively simply port
> existing 32 apps to ia64 and in the same time enjoy the perfomance of the
> new chip.
> Is it possible to force LP64 processes below 4G? Is there a compiler/linker
> switch to do so?
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


