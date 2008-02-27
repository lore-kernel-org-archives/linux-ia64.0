From: Alex Chiang <achiang@hp.com>
Date: Wed, 27 Feb 2008 00:10:57 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC]
Message-Id: <20080227001057.GE15862@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Russ Anderson <rja@sgi.com>:
> 
> How about putting back some of the code that avoided the problem?
> 
> The previous code must have bailed out before getting to 
> ia64_sal_physical_id_info().  

Yes, the previous code actually did this:

-       if (smp_num_cpucores = 1 && smp_num_siblings = 1)
-               return;
-
        if ((status = ia64_pal_logical_to_phys(-1, &info)) != PAL_STATUS_SUCCESS
-               printk(KERN_ERR "ia64_pal_logical_to_phys failed with %ld\n",
-                      status);
-               return;

So it never called ia64_pal_logical_to_phys nor did it call
ia64_sal_get_physical_info.

My patch changed the logic so that we would at least try to call
both to extract what useful information we could (because various
HP platforms implement either one, both, or neither calls).

> Did it print out an error message, such as "No logical to
> physical processor mapping " or "ia64_pal_logical_to_phys
> failed with"?   What does ia64_pal_logical_to_phys() return on
> a tiger box?

On a Tiger, we didn't see any printks because we bailed before
even making the PAL code. But if it *did* make the PAL call, we
would have seen that printk above.

My earlier patch (that caused a regression) changed that code
path to:

	- always make the PAL call

	- if return value was not success *and* something other
	  than "not implemented" then print the error and return

	- else, if the PAL call was merely unimplemented, then
	  make the SAL call to try and get at least something
	  useful

	- if the SAL call was unsuccessful as well (where
	  unsuccessful *includes* unimplemented condition) then
	  bail

	- finally, combine what we could successfully figure out
	  and stash it away for later so when a user does a cat
	  /proc/cpuinfo, at best they'll get something more
	  useful than before, and at worst, there will be no
	  change from prior behavior

I think that was a pretty reasonable approach, but I admit it was
based on an assumption that an unimplemented SAL call would
return with -1 rather than doing something nasty like hang the
box.

I think that the Tiger firmware is actually buggy and should be
returning -1 rather than doing the Bad Thing(tm).

The patch I just sent out a bit ago should be a reasonable
workaround.

Thanks.

/ac

