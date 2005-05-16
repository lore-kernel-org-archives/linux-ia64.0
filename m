From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Mon, 16 May 2005 05:34:06 +0000
Subject: Re: [patch] improve SMP reschedule and idle routines
Message-Id: <428830CE.6010602@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42881FE2.2000302@yahoo.com.au>	<20050515.220455.59467677.davem@davemloft.net>	<42882D44.50302@yahoo.com.au> <20050515.222722.63128129.davem@davemloft.net>
In-Reply-To: <20050515.222722.63128129.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: anton@samba.org, paulus@samba.org, linux-ia64@vger.kernel.org, mingo@elte.hu, linux-kernel@vger.kernel.org

David S. Miller wrote:
> From: Nick Piggin <nickpiggin@yahoo.com.au>
> Date: Mon, 16 May 2005 15:19:00 +1000
> 
> 
>>The other obvious problem with sparc64 that I didn't tackle is
>>your secondary CPU bringup - those CPUs will be calling cpu_idle
>>with preempt enabled as was previously required, but now should
>>have preempt disabled (ie. arch/sparc64/kernel/trampoline.S:
>>call cpu_idle)
> 
> 
> And adding a preempt_disable() call to the end of
> arch/sparc64/kernel/smp.c:smp_callin() won't work
> because?
> 

No that looks like it should work. If that is the "right"
place to put it, then that's perfect. I'll resend the patch
to you privately.

