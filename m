From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 07 Mar 2007 22:20:55 +0000
Subject: Re: NULL pointer in ia64/irq_chip-mask/unmask function (V2)
Message-Id: <m1vehcbsqg.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703072138.l27LcRVE022938@agluck-lia64.sc.intel.com>
In-Reply-To: <200703072138.l27LcRVE022938@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> This patch now has an extra piece for the SGI specific
> occurance of the same context (as noted by Eric).  Just
> posting here in case I misunderstood, or mis-typed while
> applying (especially as to make this complile I had to make
> mask_irq() and unmasq_irq() global instead of static).

This patch appears wrong.

The mask/unmask methods are specific to an interrupt handler type,
so I think the mask_irq/unmask_irq methods you made global actually
happen to be iosapic specific.

The point of masking the irq when we are moving it is to ensure the
operation is atomic, and we won't get an irq sent to some halfway
state.

That said sn looks to be doing something fishing (SAL calls and
a whole extra layer of interrupt functions) and it seems not
to implement disable or enable methods so implementing a noop
mask/unmask operation is probably appropriate.

The change that triggered this is the function
move_native_irq was modified to call mask/unmask instead
of enable/disable as the default enable/disable routines
are noops that delay masking the interrupt until it occurs
one more time.  Those semantics were completely inappropriate
for reprogramming the interrupt controller although they were
perfectly fine for drivers.

Eric
