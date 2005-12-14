From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 Dec 2005 00:25:50 +0000
Subject: RE: [patch 2/2] /dev/mem validate mmap requests
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0531E4BB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200512131656.26722.bjorn.helgaas@hp.com>
In-Reply-To: <200512131656.26722.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Cc: linux-ia64@vger.kernel.org

> Tony, can you ack/nak this please?  It touches both ia64 and generic
> code.

So if someone tries to mmap a range that spans across more than
one EFI memory descriptor, the size will get trimmed back to an
EFI memory boundary.  Isn't that a problem since 1<<EFI_PAGE_SHIFT
is less than the default ia64 Linux page size?

I think you may need a more complex checker that does aggregation
of adjacent efi memory descriptors with the same attributes.

-Tony
