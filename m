From: Bill Davidsen <davidsen@tmr.com>
Date: Thu, 22 Dec 2005 21:45:08 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <43AB1E64.6010504@tmr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051214232526.9039.15753.sendpatchset@tomahawk.engr.sgi.com>	 <20051215225040.GA9086@agluck-lia64.sc.intel.com>	 <Pine.LNX.4.64.0512151750500.1678@montezuma.fsmlabs.com>	 <1134698636.12086.222.camel@mindpipe>	 <00b201c601e6$30c87ff0$d6069aa3@johnhaonw7lw1r> <1134703152.12086.231.camel@mindpipe>
In-Reply-To: <1134703152.12086.231.camel@mindpipe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lee Revell <rlrevell@joe-job.com>
Cc: Zwane Mwaikambo <zwane@arm.linux.org.uk>, "Luck, Tony" <tony.luck@intel.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

Lee Revell wrote:
> On Thu, 2005-12-15 at 18:12 -0800, John Hawkes wrote:
> 
>>From: "Lee Revell" <rlrevell@joe-job.com>
>>
>>>There are 10 drivers that udelay(10000) or more and a TON that
>>>udelay(1000).  Turning those all into 1ms+ non preemptible sections will
>>>be very bad.
>>
>>What about 100usec non-preemptible sections?
> 
> 
> That will disappear into the noise, in normal usage these happen all the
> time.  500usec non preemptible regions are rare (~1 hour to show up) and
> 1ms very rare (24 hours).  My tests show that 300 usec or so is a good
> place to draw the line if you don't want it to show up in latency tests.

I may be misreading the original post, but the problem is described as 
one where the TSC is not syncronised and a CPU switch takes place. Would 
the correct solution be to somehow set CPU affinity temporarily in such 
a way as to avoid disabling preempt at all?

The preempt doesn't seem to be the root problem, so it's unlikely to be 
the best solution...

-- 
    -bill davidsen (davidsen@tmr.com)
"The secret to procrastination is to put things off until the
  last possible moment - but no longer"  -me
