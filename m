From: Christoph Lameter <cl@linux-foundation.org>
Date: Tue, 19 Jan 2010 21:50:34 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <alpine.DEB.2.00.1001191545170.26683@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home>
 <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home> <20100119212935.GG11010@ldl.fc.hp.com>
In-Reply-To: <20100119212935.GG11010@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Tue, 19 Jan 2010, Alex Chiang wrote:

> > Thats a kfree of an object not allocated with a slab allocator.
> > Recovery is easy in such a case: Dont free the object.
>
> I don't get it.
>
> static int sr_probe(struct device *dev)
> {
> 	/* ... */
>
> 	cd = kzalloc(sizeof(*cd), GFP_KERNEL);
> 	if (!cd)
> 		goto fail;
>
> 	/* ... */
>
> 	fail_put:
> 		put_disk(disk);
> 	fail_free:
> 		kfree(cd);
> }
>
> The kfree() is balanced with kzalloc(). Unless the stack trace is
> lying to us?

cd is pointing for some reason to an object not allocated. This would mean
that kzalloc returns such an object(?). Theoretically one could free a
statically allocated object using kmem_cache_free() and it would be put on
thefreelist. Then it could be returned from kzalloc (all only if debuging
is off)... so

Could you boot with full debugging?

Either switch on

CONFIG_SLUB_DEBUG_ON

or pass

	slub_debug

on the kernel command line.


