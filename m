From: Will Deacon <will.deacon@arm.com>
Date: Thu, 25 May 2017 14:28:30 +0000
Subject: Re: [PATCH 1/1] futex: remove duplicated code
Message-Id: <20170525142829.GO2859@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170515130742.18357-1-jslaby@suse.cz>
 <20170515131644.GA3605@arm.com>
 <alpine.DEB.2.20.1705222259580.2407@nanos>
In-Reply-To: <alpine.DEB.2.20.1705222259580.2407@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Catalin Marinas <catalin.marinas@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm>

On Mon, May 22, 2017 at 11:11:33PM +0200, Thomas Gleixner wrote:
> On Mon, 15 May 2017, Will Deacon wrote:
> > On Mon, May 15, 2017 at 03:07:42PM +0200, Jiri Slaby wrote:
> > > There is code duplicated over all architecture's headers for
> > > futex_atomic_op_inuser. Namely op decoding, access_ok check for uaddr,
> > > and comparison of the result.
> > > 
> > > Remove this duplication and leave up to the arches only the needed
> > > assembly which is now in arch_futex_atomic_op_inuser.
> > > 
> > > Note that s390 removed access_ok check in d12a29703 ("s390/uaccess:
> > > remove pointless access_ok() checks") as access_ok there returns true.
> > > We introduce it back to the helper for the sake of simplicity (it gets
> > > optimized away anyway).
> > 
> > Whilst I think this is a good idea, the code in question actually results
> > in undefined behaviour per the C spec and is reported by UBSAN. See my
> > patch fixing arm64 here (which I'd forgotten about):
> > 
> > https://www.spinics.net/lists/linux-arch/msg38564.html
> > 
> > But, as stated in the thread above, I think we should go a step further
> > and remove FUTEX_OP_{OR,ANDN,XOR,OPARG_SHIFT} altogether. They don't
> > appear to be used by userspace, and this whole thing is a total mess.
> 
> You wish. The constants are not used, but FUTEX_WAKE_OP _IS_ used by
> glibc. They only have one argument it seems:
> 
>    #define FUTEX_OP_CLEAR_WAKE_IF_GT_ONE      ((4 << 24) | 1)
> 
> but I'm pretty sure that there is enough (probably horrible) code (think
> java) out there using FUTEX_WAKE_OP for whatever (non)sensical reasons in
> any available combination.

Indeed, and I'm not proposing to get rid of that. It's the grossly
over-engineered array of operations and the FUTEX_OP_OPARG_SHIFT modifier
that I think we should kill. The latter likely behaves differently across
different architectures and potentially depending on the toolchain you used
to build the kernel.

Does anybody know the history behind the interface design?

Will
