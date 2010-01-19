From: Alex Chiang <achiang@hp.com>
Date: Tue, 19 Jan 2010 21:29:35 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <20100119212935.GG11010@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home> <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home>
In-Reply-To: <alpine.DEB.2.00.1001191427370.26683@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org

* Christoph Lameter <cl@linux-foundation.org>:
> On Tue, 19 Jan 2010, Alex Chiang wrote:
> 
> > Well, making progress (maybe?).
> 
> Yes I think this is the fix.
> 
> > Now we're hitting a BUG_ON().
> 
> Thats a kfree of an object not allocated with a slab allocator.
> Recovery is easy in such a case: Dont free the object.

I don't get it.

static int sr_probe(struct device *dev)
{
	/* ... */

	cd = kzalloc(sizeof(*cd), GFP_KERNEL);
	if (!cd)
		goto fail;

	/* ... */

	fail_put:
		put_disk(disk);
	fail_free:
		kfree(cd);
}

The kfree() is balanced with kzalloc(). Unless the stack trace is
lying to us?

/ac
