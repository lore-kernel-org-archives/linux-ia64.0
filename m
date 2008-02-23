From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 23 Feb 2008 00:02:23 +0000
Subject: RE: ia64_mca_cpe_int_handler
Message-Id: <1FE6DD409037234FAB833C420AA843ECA42395@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BF02EC.4080102@bull.net>
In-Reply-To: <47BF02EC.4080102@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Would it be unreasonable to disable the CPE interrupt, then enable
> do the local_irq_enable() ?  It would functionally be the same as
> going into polling mode for the length of time it takes to handle
> the CPE, then returning to interrupt mode.  I think that would
> meet both the letter and the intent of the SAL spec.

This should be OK ... same treatment would be needed in the CMC path
(Zoltan's patch already covers this by delaying the interrupt enable
there too).

Which approach is better?

Delaying the interrupt enable may be a simpler code change (disabling
and enabling the CPE/CMC interrupt may complicate the code that
already does this for high rates of corrected interrupts).

Keeping the enable early is better for interrupt latency.

-Tony
