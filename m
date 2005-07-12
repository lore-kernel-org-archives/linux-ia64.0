From: Dean Nelson <dcn@sgi.com>
Date: Tue, 12 Jul 2005 20:00:15 +0000
Subject: Re: [PATCH] fix call of smp_processor_id() by XPC while preemptible
Message-Id: <20050712200015.GA12032@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D41A65.mailx8QB11670O@aqua.americas.sgi.com>
In-Reply-To: <42D41A65.mailx8QB11670O@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 12, 2005 at 12:39:55PM -0700, Luck, Tony wrote:
> >XPC calls smp_processor_id() twice from xpc_setup_infrastructure() with
> >preemption enabled, which gets flagged if 'DEBUG_PREEMPT=y'. This patch
> >disables preemption around a now single call to smp_processor_id(). Note
> >that it doesn't matter if the thread is moved to another processor once
> >it has the processor ID.
> 
> So the code becomes effectively:
> 
> 	cpuid = pick_a_random_online_cpuid();
> 
> What is the higher level function that you are doing here that is OK
> with that?
> 
> -Tony
> 
> P.S. The cpu number you picked may not still be online by the time
> you use it.

From the cpuid we get the nasid and physical cpuid which are passed to
another partition (also running XPC) which it uses to target IPIs for
communication purposes back at 'this' partition. The code is set up
to deal with partitions disappearing.

