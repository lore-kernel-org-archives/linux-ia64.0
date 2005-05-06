From: Russ Anderson <rja@sgi.com>
Date: Fri, 06 May 2005 16:15:48 +0000
Subject: Re: MINSTATE_START_SAVE_MIN_PHYS looking very confused
Message-Id: <200505061615.j46GFm1L4874595@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17019.24133.738017.806202@napali.hpl.hp.com>
In-Reply-To: <17019.24133.738017.806202@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
>          However, the bigger issue to me is: given that we have a
> separate INIT stack, why bother distinguishing between an INIT that
> hits user-level vs. one that hits the kernel.  It's not possible to
> handle nested INITs anyhow, so why not just simplify that code to
> always switch to the INIT stack?

I don't know the historical reason for the user/kernel differences
in the code.  Maybe concerns about saving the right state information
depending on the context?  You're right that it could be made to 
treat both the same.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
