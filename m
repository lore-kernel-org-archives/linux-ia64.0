From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 22 Jul 2003 02:58:30 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105884272104553@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 21, 2003 at 08:16:04PM -0600, Bjorn Helgaas wrote:

> I sort of object to adding a parallel function just to extract
> regions with a different attribute.

As do I.

> I'd rather rework efi_memmap_walk to call the callback for *every*
> memory descriptor, and make the callback responsible for filtering
> out the regions of interest.

I'd prefer we cleaned up the entire EFI code to do this and a few
other things differently --- however, given the status of 2.4.x I'm
not sure this is desirable?

> The only problem is that the existing callbacks would have to be
> changed.  Plus, all the trimming that's currently in efi_memmap_walk
> to make sure all the granules with WB memory are completely WB,
> would have to be reworked or pulled out into its own function.  I
> kind of like the idea of factoring it out anyway.

Given that is this acceptable for 2.4.x as-is or should I move the
code into the driver as distasteful as that is.

I'm not convinced that massive EFI API changes right now are a good
idea (not to mention I certainly have no time for them myself).



Thanks,
  --cw
