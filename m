From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 17 Nov 2008 20:58:55 +0000
Subject: RE: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C3BE45E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Ignorance being bliss?

If the module is only hitting unaligned addresses that the processor
can handle ... then ignorance might well be bliss.  The cost of
an un-reported misaligned access is anly a few cycles.  The cost
of the trap and trip to arch/ia64/kernel/unaligned.c is IIRC
somewhere in the 800-900 cycle range ... more for the printk.

If we had less of a sledgehammer to report the problem, then I'd
find it a lot easier to say that this should be enabled in
production systems.

> If this module was developed in an environment where the unaligned
> accesses could not be easily seen how does hiding the messages in
> production get them addressed?  Modules being developed in such
> environments would seem to suggest that the messages _should_ be seen in
> production?

Definitely a downside to my approach ... if the end users
don't see that they have been sold a crummy driver they
won't know that they should complain.

-Tony
