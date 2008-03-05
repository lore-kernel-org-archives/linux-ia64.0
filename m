From: Russ Anderson <rja@sgi.com>
Date: Wed, 05 Mar 2008 18:56:29 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <20080305185629.GA20014@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 05, 2008 at 02:14:52PM +0100, Zoltan Menyhart wrote:
> Thank you for your remarks.
> 
> >>The MCAs/INITs are rare.
> >
> >One hopes.  :-)
> 
> Should you have a single unrecoverable MCA, the game is over.

Depends on the definiton of "over". :-)

> Neither the original code, nor mine can log it before the machine
> is re-booted / halted.
> Only the recovered ones play.
> It is safe to continue after the recovered ones.
> You need these logs to be alerted and to program the maintenance.
> 
> Both the original code and mine can "swallow" about 1 recovered
> event / minute, and tolerate a "burst" of 2 or IA64_MAX_MCA_INIT_BUFS
> events.

That is not nearly enough.  On a large shared memory system multiple
CPUs can hit the same memory error at the same time (for example).
There are several test cases in my test environment that cause
multiple CPUs to go into MCA at the same time.  The value needs 
to scale with system size.

What happens on boot up, when salinfo reads all the old records?
Does that "burst" of records all get logged.

> The probability to have more than that _independent_ events
> in a small time frame is very very low. Therefore you can
> afford losing events of the same "burst".

Large systems turn unlikely probabilities into likely.

> >>There is no use wasting much permanent resources.
> >
> >Sometimes a necessary evil.  Normal memory allocation routines 
> >cannot be called from MCA/INIT context.
> 
> This is why I pre-allocate IA64_MAX_MCA_INIT_BUFS buffers.
> 
> >Even if the system is going down it is still nice to try to 
> >go down gracefully.  Taking a system dump and logging as 
> >much as possible is usefull, too.
> 
> You (may want to) take a dump if the event is not recovered.
> In such e case, neither the original code, nor mine does any useful
> thing :-)

My intent was not to turn this into a discussion of KDB/system
dump, but those are necessary features.  :-)
 
> >In the case where all the CPUs are INITed, what happens?
> >Does this assume only one CPU at a time processes/logs records?
> 
> I have not added my code to the INIT handler yet.
> 
> >From the SAL spec.: INIT reason code:
> 
> 0 = Received INIT signal on this processor for reasons other than machine
>     check rendezvous and CrashDump switch assertion.
> 1 = Received INIT signal on this processor during machine check rendezvous.
> 2 = Received INIT signal on this processor due to CrashDump switch 
> assertion.
> 
> I think there is no use to log anything in the cases of MCA rendezvous
> and CrashDump (that can actually dump, call the KDB).
> I intend to log the "other reasons" only, by the monarch only.

When the system is NMI'ed, all the CPUs receive an INIT.
I'll check what category that falls under.

> >>The code does not assume that the rendezvous always works.
> >
> >Could you explain.  Do you mean MCA/INIT rendezvous?
> 
> Yes.
> If everything goes fine, only one CPU, the monarch logs.
> (See also the comment in the INIT handler saying:
> FIXME: Workaround for broken proms that drive all INIT events as monarchs.)

That FIXME was to work around a case where all the CPUs rendezvoued but SAL
did not identify any of the CPUs as monarch.
 
> However, the SAL spec. allows in "OS_MCA Hand-off State" that
> "Rendezvous of other processors was required but was unsuccessful
> on one or more processors."
> 
> E.g. two non-global MCAs can happen on two CPUs, both of them can start
> to execute the MCA handler, thinking that each of them is monarch.
> My code should survive...

I have a test case that creates that scenario.  With your patch and only 
one of the MCAs (at most) end up getting logged in /var/log/salinfo/decoded .

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
