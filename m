From: john stultz <johnstul@us.ibm.com>
Date: Wed, 18 Feb 2004 21:49:44 +0000
Subject: Re: [PATCH] linux-2.6.3_ia64-cyclone_A2.patch
Message-Id: <1077140984.985.118.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077136393.985.111.camel@cog.beaverton.ibm.com>
In-Reply-To: <1077136393.985.111.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-02-18 at 13:36, David Mosberger wrote:
> >>>>> On Wed, 18 Feb 2004 12:33:14 -0800, john stultz <johnstul@us.ibm.com> said:
> 
>   john> This patch provides access to the cyclone time source found on IBM EXA
>   john> based systems (x450 and x455). This is needed on multi-node systems
>   john> where the CPU ITCs are not synchronized, causing possible time
>   john> inconsistencies.
> 
>   john> This release fixes one last minor think-o and ran overnight without any
>   john> time inconsistencies (when used in conjunction w/ the
>   john> time-interpolator-fix_A0 patch).
> 
>   john> Please consider for inclusion into your tree.
> 
> The current patch looks mostly fine to me (apart from the trailing
> whitespace again).  I'm wondering though whether cyclone.c should go
> into arch/ia64/ibm/SOMEWHERE, like we do for the SGI and HP
> platform-specific code.  Or, if Cyclone sharable with your x86-based
> platforms, perhaps it should even go somewhere in drivers?

Gah! Where is this trailing whitespace? I went through this patch
specifically eliminating any I could find. Perhaps my mail client is
trying to irritate me.

The code, while similar, isn't quite shareable w/ ia32. However, I'd be
up for moving it to a separate IBM directory if you'd prefer, although
for just a single file it seems like overkill.

thanks
-john

