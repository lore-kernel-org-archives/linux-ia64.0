From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Jul 2003 01:15:42 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105909575817537@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 21 Jul 2003 17:43:54 -0700, Christopher Wedgwood <cw@sgi.com> said:

  Chris> Hi, On SN2 we have a 'fetchop' driver which does various
  Chris> magical things with uncached memory (atomic operations within
  Chris> or across partitions).

  Chris> To support this we have efi_memmap_walk_uc defined in a very
  Chris> similar way to efi_memmap_walk.

  Chris> How do people feel about merging this in the generic code
  Chris> (rather than hiding it away in the driver or something more
  Chris> complex like abstraction and changes to the current efi
  Chris> code)?

  Chris> I'd also like to see a version of this in 2.5.x.

I really would like to see the code that's using efi_memmap_walk_uc()
first.

Also, a check like this:

  Chris> if (md->attribute = EFI_MEMORY_UC)

is almost certainly wrong (md->attribute is a bitmap).

	--david
