From: Robin Holt <holt@sgi.com>
Date: Mon, 03 Nov 2008 11:46:39 +0000
Subject: Re: [PATCH V2 0/2] enable irqs when waiting for rwlocks
Message-Id: <20081103114638.GD8483@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224777451.11530.52.camel@elijah.suse.cz> <1225443142.6825.4.camel@elijah.suse.cz> <57C9024A16AD2D4C97DC78E552063EA35A7ED9D3@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA35A7ED9D3@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Fri, Oct 31, 2008 at 01:22:56PM -0700, Luck, Tony wrote:
> > Any comments on my second patch series? Not even an Acked-by? Dislike of
> > the concept? Should I post it again?
> 
> Better response to interrupts is good, but it comes at the
> cost of longer latency acquiring the lock (in the case where
> an interrupt happens while we are waiting for the lock, and
> the lock is freed while we are off executing the interrupt
> handler).
> 
> Any suggestions on how to measure the trade-off here?  Possibly
> it doesn't matter because this may only be significant when
> the lock is heavily contended and you are probably aleady
> hosed in this case.

Just a few years of experiencal evidence.  The equivalent of this patch
has been in the SuSE SLES10 kernel for years and not been detected as
being negative.

Sorry I don't have more detail.  The person at SGI who first detected
this problem has long since left, and actually passed away from an
aneurysm a couple years ago.  The first version of the patch was in our
one-off kernel based on Redhat's 2.4 kernel.  The patch was not pushed
to SuSE and the community for SLES9.  It was in SLES10, but I can not
find our internal tracking tool's record of it (searching is failing me
this morning).  Without that, I have not been able to find why it was
not pushed to the community.

Thanks,
Robin
