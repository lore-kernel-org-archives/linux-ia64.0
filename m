From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jul 2003 20:41:51 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951148111016@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jul 2003 11:34:07 -0700, Christopher Wedgwood <cw@sgi.com> said:

  Christopher> On Thu, Jul 24, 2003 at 06:15:42PM -0700, David Mosberger wrote:

  >> I really would like to see the code that's using
  >> efi_memmap_walk_uc() first.

  Christopher> I think Jack sent this to you already

If he did, I don't remember (and I don't have it in my inbox).

  >> Also, a check like this:

  Chris> if (md->attribute = EFI_MEMORY_UC)

  >> is almost certainly wrong (md->attribute is a bitmap).

  Christopher> I think the logic here seems to have been uncached ONLY
  Christopher> (ie. all other bits zero).

There are many bits in attribute, such as MEMORY_RUNTIME etc.  The
real problem is that the code you sent me makes little sense to me.
It creates a "node_fetchops" structure for _every_ uncached block of
address space?  Will there be problems if that address space/memory is
used for other purposes?

  Christopher> I guess this falls down if new attributes are added so
  Christopher> something like:

  Christopher> if ((md->attribute & SOME_MASK) = EFI_MEMORY_UC)
  Christopher> [...]

  Christopher> would then be required.  Since this is the only
  Christopher> consumer of this interface thus far I'm not sure it's
  Christopher> obvious how the function should best work.

I think what we really want here is two bitmasks: one telling us which
bits we care about and one telling us what values those bits should be
set to.  As it stands, efi_memmap_walk_uc() doesn't do what it
advertises to do and instead does something very specific to SN2.

  Christopher> The issue right now seems to be whether or not this or
  Christopher> some variation of this is useful and/or desirable in
  Christopher> the mainline kernel or whether for now it's best to
  Christopher> hide this in the driver until a later stage when the
  Christopher> EFI interfaces are abstracted out a little more to make
  Christopher> this easier?

Can you work with Tony on this?  Since he's Mr. MCA (you OK with this
title, Tony? ;-) and since we'll have to map the MINSTATE area UC, I
think we want to make sure that the interface can handle all of this.

	--david
