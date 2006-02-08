From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 08 Feb 2006 11:59:46 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <20060208115946.GN3524@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060208035112.GM3524@stusta.de> <200602080552.k185q9g07813@unix-os.sc.intel.com>
In-Reply-To: <200602080552.k185q9g07813@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Keith Owens' <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 07, 2006 at 09:52:09PM -0800, Chen, Kenneth W wrote:
> > > > >You patch does more than what you described and is wrong.  Selecting
> > > > >platform type should not be tied into selecting SMP nor should it tied
> > >...
> > > I'm not disagreeing with the SMP bit.  In my very first reply, I
> > >...
> > 
> > It might be related to the fact that I'm not a native English speaker, 
> > but for me this reads as if you contradict yourself, and I have 
> > therefore problems understanding your emails.
> 
> Yeah, I've been flip-flopping on CONFIG_SMP.  I just don't have strong
> opinion one way or the other. Having said that, I don't think we should
> mix the CONFIG_IA64_GENERIC, which is defined to select platform type
> with smp/processor type etc.
> 
> But for the bit that this thread started, which disables CONFIG_MCKINLEY
> for CONFIG_IA64_GENERIC, it is totally wrong and is the "over my dead
> body" type of thing.

My initial patch that started this thread was to remove all select's 
from CONFIG_IA64_GENERIC.

Is this OK for you?

> - Ken

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

