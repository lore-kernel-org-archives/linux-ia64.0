From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 27 Sep 2005 02:47:43 +0000
Subject: Re: [patch 2.6.14-rc2 0/5] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <12c511ca050926194784b63e5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F047E9021@scsmsx401.amr.corp.intel.com>
	 <20050926224603.GD16113@esmail.cup.hp.com>
	 <20050927001427.GC5640@tuxdriver.com>
In-Reply-To: <20050927001427.GC5640@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>, "Luck, Tony" <tony.luck@intel.com>, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>, gregkh@suse.de

> OK...I read Tony's patch post to imply that he is consenting to lib/ as
> the location as well.  Tony, please speak-up if that is not the case.

lib/ is certainly better than drivers/pci ... so unless anyone has a better
location, we'll go with that.

> If everyone agrees, I'll re-collect the patches moving everything to
> lib/ (plus the one I forgot to repost) and Tony's patch and repost.

My patch only removed the include for linux/pci.h and asm/pci.h
(as per Mathhew Wilcox's suggestion) and then cleaned  up the
resulting compilation fluff.  There are a few more PCI references in
comments and printk messages that should be cleaned up too.
Oh, I only compile tested for ia64 ... so it needs compile-testing
for x86-64, and boot testing for both archs.

> So, who is the proper committer for this?  Tony?  Or should I send
> them directly to Andrew?

I have one other change to swiotlb.c (from Alex Williamson) sitting
in my "test" tree, which needs to not get lost.  I'm happy to drive
this (target 2.6.15 ... this isn't 2.6.14 bug fix material). So long as
I don't get burned to a crisp for offloading this Intel specific[1] stuff
into the generic part of the tree.

-Tony

[1] Only ia64 and em64t use this right now.
