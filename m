From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 14 Dec 2005 15:48:56 +0000
Subject: Re: [patch 2/2] /dev/mem validate mmap requests
Message-Id: <200512140848.56570.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0531E4BB@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0531E4BB@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org

On Tuesday 13 December 2005 5:25 pm, Luck, Tony wrote:
> > Tony, can you ack/nak this please?  It touches both ia64 and generic
> > code.
> 
> So if someone tries to mmap a range that spans across more than
> one EFI memory descriptor, the size will get trimmed back to an
> EFI memory boundary.  Isn't that a problem since 1<<EFI_PAGE_SHIFT
> is less than the default ia64 Linux page size?

The EFI page size is smaller than the Linux page size, but firmware
typically coalesces adjacent ranges with the same attributes.

> I think you may need a more complex checker that does aggregation
> of adjacent efi memory descriptors with the same attributes.

We could, but I don't think it's worth it at this point.  We've
been using the same simple-minded scheme for validating /dev/mem
read & write requests for quite a while with no problems, and I
don't want to over-engineer this.

If hot-plug memory is ever finished, the checker may have to
be extended to comprehend regions described by ACPI as well as
those described in the boot-time EFI memory map.  I think that
would be the right time to make it smarter about spanning
descriptors.
