From: Dean Nelson <dcn@sgi.com>
Date: Thu, 29 Jul 2004 16:10:06 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040729161006.GA4145@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 15, 2004 at 09:58:27PM +0100, Christoph Hellwig wrote:
> On Wed, Jul 14, 2004 at 11:01:08AM -0500, Dean Nelson wrote:
> > > No.  Please don't make random sal calls from modules.
> > 
> > We're only making one sal call (i.e., SN_SAL_GET_PARTITION_ADDR) to get the
> > address of a partition's reserved page.
> 
> Then please provide some accessor from core SN2 code.  If that partition addr
> is constant after bootup a global variable should do it, else a small wrapper
> function.
> 
> > In include/asm-ia64/sn/sn_sal.h, there are inline functions that are wrappers
> > for the SAL_CALL() macro, (for example, ia64_sn_get_console_nasid()). Is this
> > what you are looking for? (But even if we did create such a function, we'd
> > still need to export sal_lock and ia64_sal because both are referenced by the
> > SAL_CALL() macro.) I'd hate to put such an abstraction into sal.c, since the
> > functionality of my sal call is ia64/sn specific, and sal.c is generic
> > ia64.
> 
> similar to that, just not inline.


David and Tony,

The modules that are part of this series of patches need to be able to call
into SAL. They do this by way of the following inline functions, which are
currently defined (or will be) in sn_sal.h.

	sn_partition_reserved_page_pa() calls
		SAL_CALL(, SN_SAL_GET_PARTITION_ADDR, ...)

	sn_register_xp_addr_region() calls
		SAL_CALL(, SN_SAL_XP_ADDR_REGION, ...)

	sn_register_nofault_code() calls
		SAL_CALL(, SN_SAL_NO_FAULT_ZONE_VIRTUAL, ...)

	sn_partition_serial_number_val() calls
		ia64_sn_partition_serial_get() calls
			SAL_CALL(, SN_SAL_PARTITION_SERIAL_GET, ...)

	sn_local_partid() calls
		ia64_sn_sysctl_partition_get() calls
			SAL_CALL(, SN_SAL_SYSCTL_PARTITION_GET, ...)

	sn_change_coherence() calls
		SAL_CALL(, SN_SAL_COHERENCE, ...)

	sn_change_memprotect() calls
		SAL_CALL_NOLOCK(, SN_SAL_MEMPROTECT, ...)

The question is whether we export ia64_sal and sal_lock? Or change these
inline functions to no longer be inline, move them to a new file (sn_sal.c),
and export the individual function names?

From my point of view the first solution is better from the standpoint of
the diagnostics folks who write tests that need to make SAL calls. It doesn't
seem appropriate that the linux kernel be the repository of a bunch of ad hoc
and miscellaneous SAL wrapper functions that no one but the diagnostics folks
use.

I would like to know your opinions on the direction to go with this.

Thanks,
Dean

