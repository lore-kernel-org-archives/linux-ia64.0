From: Pat Gefre <pfg@sgi.com>
Date: Mon, 13 Oct 2003 15:22:17 +0000
Subject: Re: [PATCH] Altix I/O code cleanup
Message-Id: <marc-linux-ia64-106605905131091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 13 Oct 2003, Christoph Hellwig wrote:

+ On Fri, Oct 10, 2003 at 04:49:57PM -0500, Patrick Gefre wrote:
+ > This is my first patch for this - more to come ....
+ 
+ It would be nice to give those credits who submitted those patches.
+ And life would be a lot simpler if you wouldn't submit my individual
+ patches instead of putting them into a big one - this gives useful
+ entries in the revision history and allows for easier binary search
+ if something goes wrong.

I'm trying to submit this code in small patches - yet still have *some*
amount of utility in them. Some of the code that you submitted had
already been update in our trees by someone else.


+ 
+ p.s. the right list for this would probably be linux-ia64@vger.kernel.org

OK I switched it over.


+ 
+ >  
+ >  void *
+ > -snia_kmem_zalloc(size_t size, int flag)
+ > +snia_kmem_zalloc(size_t size)
+ >  {
+ >          void *ptr = kmalloc(size, GFP_KERNEL);
+ 
+ passing a gfp_mask down here would make sense..

Future patches will remove this function all together.

+ 
+ > - * the alloc/free_node routines do a simple kmalloc for now ..
+ > - */
+ > -void *
+ > -snia_kmem_alloc_node(register size_t size, register int flags, cnodeid_t node)
+ > -{
+ > -	/* someday will Allocate on node 'node' */
+ > -	return(kmalloc(size, GFP_KERNEL));
+ > -}
+ > -
+ > -void *
+ > -snia_kmem_zalloc_node(register size_t size, register int flags, cnodeid_t node)
+ > -{
+ > -	void *ptr = kmalloc(size, GFP_KERNEL);
+ > -	if ( ptr )
+ > -		BZERO(ptr, size);
+ > -        return(ptr);
+ > -}
+ 
+ Why do you remove the per-nod wrappers?  Unlike the other these actually
+ had some use as preparation for a node-aware kmalloc..

It's easy enough to put back in at a future date - when we can do this.


+ 
+ >  	int rc;
+ > -	extern void * snia_kmem_zalloc(size_t size, int flag);
+ > +	extern void * snia_kmem_zalloc(size_t size);
+ 
+ This is in a header, isn't it?
+ 
+ >  
+ > -	xvolinfo = snia_kmem_zalloc(sizeof(struct xswitch_vol_s), GFP_KERNEL);
+ > +	xvolinfo = snia_kmem_zalloc(sizeof(struct xswitch_vol_s));
+ 
+ You still need to handle a NULL return here.
+ 
+ >  
+ > -	intr_hdl = snia_kmem_alloc_node(sizeof(struct hub_intr_s), KM_NOSLEEP, cnode);
+ > +	intr_hdl = kmalloc(sizeof(struct hub_intr_s), GFP_KERNEL);
+ >  	ASSERT_ALWAYS(intr_hdl);
+ 
+ NULL return not handled again (and the assert is totally useless)
+ 
+ > -#define NEWAf(ptr,n,f)	(ptr = snia_kmem_zalloc((n)*sizeof (*(ptr)), (f&PCIIO_NOSLEEP)?KM_NOSLEEP:KM_SLEEP))
+ > -#define NEWA(ptr,n)	(ptr = snia_kmem_zalloc((n)*sizeof (*(ptr)), KM_SLEEP))
+ > +#define NEWAf(ptr,n,f)	(ptr = snia_kmem_zalloc((n)*sizeof (*(ptr))))
+ > +#define NEWA(ptr,n)	(ptr = snia_kmem_zalloc((n)*sizeof (*(ptr))))
+ >  #define DELA(ptr,n)	(kfree(ptr))
+ 
+ What about killing this stupid wrappers while you're at it?
+  Also PCIIO_NOSLEEP is never set.
+ 

Yes coming.

