From: John Levon <levon@movementarian.org>
Date: Wed, 08 Oct 2003 19:37:56 +0000
Subject: Re: [PATCH] kill pointless perfmon abstractions
Message-Id: <marc-linux-ia64-106564201225917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106562954910433@msgid-missing>
In-Reply-To: <marc-linux-ia64-106562954910433@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 08, 2003 at 11:51:14AM -0700, Stephane Eranian wrote:

> Well, it is because you only know part of the story ;-< These abstractions
> are here to mask differences between the various kernels out there.

I'd suspected that it might be an issue with 2.4 kernels so I checked
against 2.4.22 - none of the removed macros even exist or are relevant.
I understand that it can be often be useful to allow easy merges with
2.4, but it doesn't seem to apply in this case.

> RH EL, and Suse SLES.

I must be missing something here. Why are vendor kernels at all relevant
to Linus's tree ? Vendor kernels are surely a vendor problem.

Even if they were: there's a much better way to do this. For example,
instead of pfm_irq_handler_t, simply use irqreturn_t in the source (so
it looks like 2.6 code). Then vendors can do :

#include "vendor.h"

or whatever that has
#define irqreturn_t void, #define IRQ_HANDLED /* nothing */, etc.

I believe this is general approach preferred by, for example, the net
drivers. It means that the Linus kernel tree looks sane, whilst not
sacrificing any merging ability with older trees.

Another obvious candidate here is pfm_do_munmap()

regards,
john

-- 
Khendon's Law:
If the same point is made twice by the same person, the thread is over.
