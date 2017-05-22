From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 22 May 2017 21:11:33 +0000
Subject: Re: [PATCH 1/1] futex: remove duplicated code
Message-Id: <alpine.DEB.2.20.1705222259580.2407@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170515130742.18357-1-jslaby@suse.cz>
 <20170515131644.GA3605@arm.com>
In-Reply-To: <20170515131644.GA3605@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, x86@kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Ingo Molnar <mingo@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-xtensa@linux-xtensa.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>

On Mon, 15 May 2017, Will Deacon wrote:
> Hi Jiri,
> 
> On Mon, May 15, 2017 at 03:07:42PM +0200, Jiri Slaby wrote:
> > There is code duplicated over all architecture's headers for
> > futex_atomic_op_inuser. Namely op decoding, access_ok check for uaddr,
> > and comparison of the result.
> > 
> > Remove this duplication and leave up to the arches only the needed
> > assembly which is now in arch_futex_atomic_op_inuser.
> > 
> > Note that s390 removed access_ok check in d12a29703 ("s390/uaccess:
> > remove pointless access_ok() checks") as access_ok there returns true.
> > We introduce it back to the helper for the sake of simplicity (it gets
> > optimized away anyway).
> 
> Whilst I think this is a good idea, the code in question actually results
> in undefined behaviour per the C spec and is reported by UBSAN. See my
> patch fixing arm64 here (which I'd forgotten about):
> 
> https://www.spinics.net/lists/linux-arch/msg38564.html
> 
> But, as stated in the thread above, I think we should go a step further
> and remove FUTEX_OP_{OR,ANDN,XOR,OPARG_SHIFT} altogether. They don't
> appear to be used by userspace, and this whole thing is a total mess.

You wish. The constants are not used, but FUTEX_WAKE_OP _IS_ used by
glibc. They only have one argument it seems:

   #define FUTEX_OP_CLEAR_WAKE_IF_GT_ONE      ((4 << 24) | 1)

but I'm pretty sure that there is enough (probably horrible) code (think
java) out there using FUTEX_WAKE_OP for whatever (non)sensical reasons in
any available combination.

Thanks,

	tglx
