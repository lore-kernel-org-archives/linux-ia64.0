From: Rich Altmaier <richa@sgi.com>
Date: Thu, 20 Nov 2003 17:25:59 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106934978121449@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just to add a small note to Jack's comments, the reason for the
existance of this "globally synchronized hi-res" counter is exactly
for scheduling.  On IRIX we use this in the frame-scheduler, to
achieve order(tens of microsecond) simultaneous launch of processes on
multiple CPUs for hard realtime.

The counter is replicated in each memory controller, where the
NUMAflex interconnect provides a broadcast clock signal to drive them.
It's a fairly cool feature, and the realtime people love it...

FYI, Rich


Jack Steiner wrote:

> 
> 
> This is slightly off-topic, but the shared platform counter on the SGI 
> platform isnt a single counter. The counter is replicated in each chipset
> It is synchronized thruout the system so that all cpus will see
> the same value - ie., no drift. Reading the counter does not required any 
> off-node references. There shouldnt be any scaling issues. However,
> reading the ITC is faster & preferred if intercpu drift is not an issue.
> 
> 


