From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 22 Jul 2003 02:16:04 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105884018903130@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 21 July 2003 6:43 pm, Christopher Wedgwood wrote:
> To support this we have efi_memmap_walk_uc defined in a very similar
> way to efi_memmap_walk.

I sort of object to adding a parallel function just to extract
regions with a different attribute.  I'd rather rework efi_memmap_walk
to call the callback for *every* memory descriptor, and make the
callback responsible for filtering out the regions of interest.

The only problem is that the existing callbacks would have
to be changed.  Plus, all the trimming that's currently in
efi_memmap_walk to make sure all the granules with WB
memory are completely WB, would have to be reworked
or pulled out into its own function.  I kind of like the idea
of factoring it out anyway.

Bjorn

