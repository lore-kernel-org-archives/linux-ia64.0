From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Jul 2003 18:45:40 +0000
Subject: RE: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105950435602394@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> would then be required.  Since this is the only consumer of this
> interface thus far I'm not sure it's obvious how the function should
> best work.
> 
> 
> 
> The issue right now seems to be whether or not this or some variation
> of this is useful and/or desirable in the mainline kernel or whether
> for now it's best to hide this in the driver until a later stage when
> the EFI interfaces are abstracted out a little more to make this
> easier?

Even though you are the only user ... it would seem prudent
to define some generic interface.  Right now you just assume
(correctly) that all the uncacheable memory has been ignored
by Linux.  There are two problems with this:

1) Someday that might change. E.g. Linux might need to alloc uncacheable
   memory for min_state areas for more complex MCA recovery

2) There is no way for another non-kernel user of uncacheable
   memory to share the resource with you.

-Tony
