From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 16 Jul 2005 01:15:16 +0000
Subject: Re: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <20050716011516.GA14233@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 14, 2005 at 02:17:47PM -0700, Magenheimer, Dan (HP Labs Fort Collins) wrote:
> Revision 3.  Incorporates some more feedback and
> a minor bug fix.

Looks nice.  One thing that bothers me is that privop.h is unsymmetic,
I'd rather see the Xen variants of the routines in asm/privop.h aswell.
Also in the early console setup please put the return on a separate line
from the if clause.

It would be very nice if you could submit the additional abstractions
as a first patch as soon as possible and post a full patch ontop of it
later that includes the new files aswell.

