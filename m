From: Dean Nelson <dcn@sgi.com>
Date: Wed, 02 Nov 2005 21:34:39 +0000
Subject: Re: [Patch 2.6.14] Extend notify_die() hooks for IA64
Message-Id: <20051102213439.GA4455@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5844.1130898771@kao2.melbourne.sgi.com>
In-Reply-To: <5844.1130898771@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 02, 2005 at 02:29:21PM +1100, Keith Owens wrote:
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
> 
> DIE_OOPS added.
> 
> The check for kprobe's break numbers has been moved from traps.c to
> kprobes.c, allowing DIE_BREAK to be used for any additional break
> numbers, i.e. it is no longer kprobes specific.
> 
> Hooks for kernel debuggers and kernel dumpers added, ENTER and LEAVE.
> Both of these disable the system for long periods which impact on
> watchdogs and heartbeat systems in general.  More patches to come that
> use these events to reset watchdogs and heartbeats.
> 
> unregister_die_notifier() added and both routines exported.  Requested
> by Dean Nelson.
> 
> Lock removed from {un,}register_die_notifier.  notifier_chain_register()
> already takes a lock.  Also the generic notifier chain locking is being
> reworked to distinguish between callbacks that can block and those that
> cannot, the lock in {un,}register_die_notifier would interfere with
> that change.  http://marc.theaimsgroup.com/?l=linux-kernel&m3018709002036&w=2
> 
> Leading white space removed from arch/ia64/kernel/kprobes.c.
> 
> Signed-off-by: Keith Owens <kaos@sgi.com>


Acked-by: Dean Nelson <dcn@sgi.com>

I applied this patch to the latest Tony Luck test tree and ran some
tests related to XPC's usage of the notify_die() callouts on an SGI Altix.

XPC only cares about the following notify_die() events:

	DIE_MACHINE_RESTART
	DIE_MACHINE_HALT
	DIE_MCA_MONARCH_ENTER/DIE_INIT_MONARCH_ENTER
	DIE_MCA_MONARCH_LEAVE/DIE_INIT_MONARCH_LEAVE

I called panic() and induced a MCA error, both worked as expected. I did
have trouble trying to induce a recoverable MCA due to a problem with
our error injector. It was not an issue with this patch since our error
injector was also failing on a vanilla Tony Luck test tree (i.e., minus
your patch).
