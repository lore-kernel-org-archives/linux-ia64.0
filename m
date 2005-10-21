From: Dean Nelson <dcn@sgi.com>
Date: Fri, 21 Oct 2005 19:00:27 +0000
Subject: Re: [RFC] Extend notify_die() hooks for IA64
Message-Id: <20051021190027.GA20883@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10137.1128667602@kao2.melbourne.sgi.com>
In-Reply-To: <10137.1128667602@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 07, 2005 at 04:46:42PM +1000, Keith Owens wrote:
> This mail is only for discussion, the patch is 2.6.15-rc1 material.  It
> has been compiled and has minimal testing.  Against 2.6.14-rc3.
> 
> notify_die() added for MCA_{MONARCH,SLAVE,RENDEZVOUS}_{ENTER,PROCESS,LEAVE} and
> INIT_{MONARCH,SLAVE}_{ENTER,PROCESS,LEAVE}.  We need multiple
> notification points for these events because they can take many seconds
> to run which has nasty effects on the behaviour of the rest of the
> system.
> 
> DIE_SS replaced by a generic DIE_FAULT which checks the vector number,
> to allow interception of faults other than SS.
> 
> DIE_MACHINE_{HALT,RESTART} added to allow last minute close down
> processing, especially when the halt/restart routines are called from
> error handlers.

I'm very interested in seeing these proposed changes be accepted in
some form if not as is. In particular, the DIE_MACHINE_RESTART and
DIE_MACHINE_HALT callouts.

XPC (as in arch/ia64/sn/kernel/xp*) has a need to notify other partitions
(SGI Altix) whenever a partition is going down in order to get them to
disengage from accessing the halting partition's memory. If this is not
done before the reset of the hardware, the other partitions can find
themselves encountering MCAs that bring them down.

Being that XPC is a module, the ability to safely unregister_die_notifier()
also would be necessary. I see that this functionality is missing. Could this
be added in as well?

Thanks,
Dean

