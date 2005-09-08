From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Sep 2005 18:05:45 +0000
Subject: RE: efi_memmapwalk re-write (please test)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0456EAF6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
In-Reply-To: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>-		start += PAGE_ALIGN(k->start);
>-		end = (start + (k->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK;

But this is just two lines ... I can't see how the unaligned "end" is
escaping past this point!

I do see a bug that the second line should be:

    end = (k->start + (k->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK;

since the "num_pages" size starts at the start of the block, not
at the possibly rounded up "start".

I'll apply this, and the clean-up bits.  I'd already made a similar
change to uncached.c (which I had mailed out yesterday, but seems to
have disappeared into the ether).

-Tony
