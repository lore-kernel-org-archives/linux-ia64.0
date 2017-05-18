From: Will Deacon <will.deacon@arm.com>
Date: Thu, 18 May 2017 17:30:10 +0000
Subject: Re: [PATCH 1/1] futex: remove duplicated code
Message-Id: <20170518173010.GK21359@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170515130742.18357-1-jslaby@suse.cz>
 <20170515131644.GA3605@arm.com>
 <14580dfc-9721-38ab-a1e0-6b4aba13b406@suse.cz>
In-Reply-To: <14580dfc-9721-38ab-a1e0-6b4aba13b406@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Slaby <jslaby@suse.cz>
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Catalin Marinas <catalin.marinas@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, May 17, 2017 at 10:01:29AM +0200, Jiri Slaby wrote:
> On 05/15/2017, 03:16 PM, Will Deacon wrote:
> > Whilst I think this is a good idea, the code in question actually results
> > in undefined behaviour per the C spec and is reported by UBSAN.
> 
> Hi, yes, I know -- this patch was the 1st from the series of 3 which I
> sent a long time ago to fix that up too. But I remember your patch, so I
> sent only this one this time.
> 
> > See my
> > patch fixing arm64 here (which I'd forgotten about):
> > 
> > https://www.spinics.net/lists/linux-arch/msg38564.html
> > 
> > But, as stated in the thread above, I think we should go a step further
> > and remove FUTEX_OP_{OR,ANDN,XOR,OPARG_SHIFT} altogether. They don't
> > appear to be used by userspace, and this whole thing is a total mess.
> > 
> > Any thoughts?
> 
> Ok, I am all for that. I think the only question is who is going to do
> the work and submit it :)? Do I understand correctly to eliminate all
> these functions and the path into the kernel? But won't this break API
> -- are there really no users of this interface?

That's the million-dollar question, really. I don't know of any code using
it, and I couldn't find any when I looked (also nothing reported by Debian
Codesearch afaict), but I was hoping linux-arch might have some thoughts
on this too.

For now, I'll queue my arm64 patch before I forget about it again!

Will
