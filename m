From: Dean Nelson <dcn@sgi.com>
Date: Thu, 15 Jul 2004 12:47:52 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040715124752.GA19900@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 14, 2004 at 11:01:08AM -0500, Dean Nelson wrote:
> On Wed, Jun 16, 2004 at 05:39:44PM +0100, Christoph Hellwig wrote:
> > On Wed, Jun 16, 2004 at 11:33:39AM -0500, Dean Nelson wrote:
> > >  #include <asm/page.h>
> > >  #include <asm/sal.h>
> > >  #include <asm/pal.h>
> > >  
> > >  spinlock_t sal_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;
> > > +EXPORT_SYMBOL(sal_lock);
> > 
> > No.  Please don't make random sal calls from modules.
> 
> We're only making one sal call (i.e., SN_SAL_GET_PARTITION_ADDR) to get the
> address of a partition's reserved page.

To be more precise, this is the only direct sal call we are making (i.e.,
using the SAL_CALL() macro directly). We are also making the following 
indirect sal calls via the following wrappers, all of which are defined as
inline functions in include/asm-ia64/sn/sn_sal.h:

	sn_register_nofault_code()
	sn_change_memprotect()
	sn_register_xp_addr_region()
	sn_local_partid()
	sn_partition_serial_number_val()

So I'll create a wrapper like these for the one remaining direct SAL_CALL()
we are making.

Being that they are all inline functions that call SAL_CALL() (one calls
SAL_CALL_NOLOCK()) still requires the exporting of sal_lock and ia64_sal.

Does all of this sound okay to you?

Thanks,
Dean
