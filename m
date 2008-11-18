From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 18 Nov 2008 07:06:53 +0000
Subject: RE: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <1226992013.32510.10.camel@nathan.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Luck, Tony píše v Po 17. 11. 2008 v 12:58 -0800:
> > Ignorance being bliss?
> 
> If the module is only hitting unaligned addresses that the processor
> can handle ... then ignorance might well be bliss.  The cost of
> an un-reported misaligned access is anly a few cycles.  The cost
> of the trap and trip to arch/ia64/kernel/unaligned.c is IIRC
> somewhere in the 800-900 cycle range ... more for the printk.
> 
> If we had less of a sledgehammer to report the problem, then I'd
> find it a lot easier to say that this should be enabled in
> production systems.
> 
> > If this module was developed in an environment where the unaligned
> > accesses could not be easily seen how does hiding the messages in
> > production get them addressed?  Modules being developed in such
> > environments would seem to suggest that the messages _should_ be seen in
> > production?
> 
> Definitely a downside to my approach ... if the end users
> don't see that they have been sold a crummy driver they
> won't know that they should complain.

Well, then let's make it a boot option (or a sysctl). The default must
be psr.ac = 1, but if the admin sees "unaligned access" messages and
knows that there is no way of getting a (timely) fix for that particular
production system, s/he should be able to turn them off.

IMO this approach solves both issues, because:

  1. Everebody is aware of the performance hit
  2. The cost of it can be minimized

Just my two cents,
Petr Tesarik


