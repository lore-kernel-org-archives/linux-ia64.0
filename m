From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 19:57:16 +0000
Subject: Re: [2.6 PATCH] Altix update
Message-Id: <16435.50076.400669.872965@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402181441.i1IEfIWX024531@fsgi900.americas.sgi.com>
In-Reply-To: <200402181441.i1IEfIWX024531@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: akpm@osdl.org, davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Feb 2004 08:41:18 -0600 (CST), Pat Gefre <pfg@sgi.com> said:

  Pat> Here's a small mod for Altix. It breaks up our 'pci fixup' function and
  Pat> has some other smallish clean ups.

  Pat> For the ia64 crowd I've added 'platform_data' back into
  Pat> include/asm-ia64/pci.h

I added this patch in my tree now with some trailing white-space
fixes, but no other changes.

As far as I can tell, platform_data never was in the the struct
pci_controller of the 2.5/2.6 tree, so it's really a new thing, not a
matter of "adding it back" (yeah it's in 2.4, but that's a separate
tree...).

	--david
