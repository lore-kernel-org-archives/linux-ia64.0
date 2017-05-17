From: Jiri Slaby <jslaby@suse.cz>
Date: Wed, 17 May 2017 08:01:29 +0000
Subject: Re: [PATCH 1/1] futex: remove duplicated code
Message-Id: <14580dfc-9721-38ab-a1e0-6b4aba13b406@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170515130742.18357-1-jslaby@suse.cz>
 <20170515131644.GA3605@arm.com>
In-Reply-To: <20170515131644.GA3605@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Catalin Marinas <catalin.marinas@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 05/15/2017, 03:16 PM, Will Deacon wrote:
> Whilst I think this is a good idea, the code in question actually results
> in undefined behaviour per the C spec and is reported by UBSAN.

Hi, yes, I know -- this patch was the 1st from the series of 3 which I
sent a long time ago to fix that up too. But I remember your patch, so I
sent only this one this time.

> See my
> patch fixing arm64 here (which I'd forgotten about):
> 
> https://www.spinics.net/lists/linux-arch/msg38564.html
> 
> But, as stated in the thread above, I think we should go a step further
> and remove FUTEX_OP_{OR,ANDN,XOR,OPARG_SHIFT} altogether. They don't
> appear to be used by userspace, and this whole thing is a total mess.
> 
> Any thoughts?

Ok, I am all for that. I think the only question is who is going to do
the work and submit it :)? Do I understand correctly to eliminate all
these functions and the path into the kernel? But won't this break API
-- are there really no users of this interface?

thanks,
-- 
js
suse labs
