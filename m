From: Matthew Wilcox <willy@debian.org>
Date: Fri, 14 Mar 2003 14:48:59 +0000
Subject: Re: [Linux-ia64] Re: [BUG] nanosleep() granularity bumps up in 2.5.64 (was: [PATCH] settimeofday() n
Message-Id: <marc-linux-ia64-105590709806095@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806094@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806094@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 14, 2003 at 03:34:36PM +0100, Eric Piel wrote:
> I think lines like that from patch-2.5.64 are very suspicious to be
> related to the bug:
> +	base->timer_jiffies = INITIAL_JIFFIES;
> +	base->tv1.index = INITIAL_JIFFIES & TVR_MASK;
> +	base->tv2.index = (INITIAL_JIFFIES >> TVR_BITS) & TVN_MASK;
> +	base->tv3.index = (INITIAL_JIFFIES >> (TVR_BITS+TVN_BITS)) & TVN_MASK;
> +	base->tv4.index = (INITIAL_JIFFIES >> (TVR_BITS+2*TVN_BITS)) &
> TVN_MASK;
> +	base->tv5.index = (INITIAL_JIFFIES >> (TVR_BITS+3*TVN_BITS)) &
> TVN_MASK;

No, I don't think so.  Those lines are for starting `jiffies' at a very
high number so we spot jiffie-wrap bugs early on.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

