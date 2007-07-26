From: Doug Chapman <doug.chapman@hp.com>
Date: Thu, 26 Jul 2007 21:58:45 +0000
Subject: RE: [PATCH] ia64: fix build failure on fs/quota.c
Message-Id: <1185487125.20910.30.camel@dchapman.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0205DE5E@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0205DE5E@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, vtaras@openvz.org, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@suse.de>

On Thu, 2007-07-26 at 14:24 -0700, Luck, Tony wrote:
> This issue wandered off onto a long thread "build fix for x86_64" which
> died out without a final patch.  Here's the summary:
> 

Ahh, thanks, I had not seen that thread.


> > +#if defined(CONFIG_X86_64) || (defined(CONFIG_IA64) && defined(CONFIG_COMPAT))
> 
> It was pointed out that x86-64 also has a CONFIG_COMPAT, so the "right"
> #ifdef mess would be:
> 
> #if defined(CONFIG_COMPAT) && (defined(CONFIG_IA64) || defined(CONFIG_X86_64))
> 
> But this was thought too ugly.  Andi Kleen proposed making a new CONFIG
> variable for this situation: CONFIG_COMPAT_FOR_U64_ALIGMNENT which could
> be set in ia64 and x86-64 Kconfig files with:
> 
> config COMPAT_FOR_U64_ALIGMNENT
> 	def_bool COMPAT
> 
> So the C-code would simply have:
> 
> #if defined(COMPAT_COMPAT_FOR_U64_ALIGMNENT)
> 
> (IIRC the syntax correctly).  Peter Anvin had some worries about future
> issues ... but I think he agreed that this was Ok.
> 
> Anyone still have any objections to this?

No objections here.  I just tried this patch and it does fix my ia64
build issue.  I agree it is a bit cleaner than the long #ifdef.

thanks,

- Doug


