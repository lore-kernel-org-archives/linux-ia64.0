From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 15 Jul 2004 20:58:27 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040715205826.GA10378@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 14, 2004 at 11:01:08AM -0500, Dean Nelson wrote:
> > No.  Please don't make random sal calls from modules.
> 
> We're only making one sal call (i.e., SN_SAL_GET_PARTITION_ADDR) to get the
> address of a partition's reserved page.

Then please provide some accessor from core SN2 code.  If that partition addr
is constant after bootup a global variable should do it, else a small wrapper
function.

> In include/asm-ia64/sn/sn_sal.h, there are inline functions that are wrappers
> for the SAL_CALL() macro, (for example, ia64_sn_get_console_nasid()). Is this
> what you are looking for? (But even if we did create such a function, we'd
> still need to export sal_lock and ia64_sal because both are referenced by the
> SAL_CALL() macro.) I'd hate to put such an abstraction into sal.c, since the
> functionality of my sal call is ia64/sn specific, and sal.c is generic
> ia64.

similar to that, just not inline.
