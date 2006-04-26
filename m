From: Jes Sorensen <jes@sgi.com>
Date: Wed, 26 Apr 2006 11:18:30 +0000
Subject: Re: [PATCH] change gen_pool allocator to not touch managed memory
Message-Id: <444F5706.4030805@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444D1A7E.mailx85W11DZZU@aqua.americas.sgi.com> <20060424181626.09966912.akpm@osdl.org> <20060425155051.GA19248@sgi.com> <444F3990.5030100@sgi.com> <20060426110856.GB19935@lnx-holt.americas.sgi.com>
In-Reply-To: <20060426110856.GB19935@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Dean Nelson <dcn@sgi.com>, Andrew Morton <akpm@osdl.org>, tony.luck@intel.com, avolkov@varma-el.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, paulus@samba.org

Robin Holt wrote:
> On Wed, Apr 26, 2006 at 11:12:48AM +0200, Jes Sorensen wrote:
>>> -	if (status)
>>> -		printk(KERN_WARNING "smp_call_function failed for "
>>> -		       "uncached_ipi_mc_drain! (%i)\n", status);
>>> +	(void) smp_call_function(uncached_ipi_mc_drain, NULL, 0, 1);
>> This thing could in theory fail so having the error check there seems
>> the right thing to me. In either case, please don't (void) the function
>> return (this is a style issue, I know).
> 
> I must be blind.  Both up and smp cases for smp_call_function appear to
> always return 0.  What am I missing?

Not on all architectures, at least PPC can return != 0 - dunno if this
is a realistic case though. If not, maybe the prototype for
smp_call_function() ought to be changed.

Cheers,
Jes
