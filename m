From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 11 Jan 2005 22:35:36 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <200501111435.36643.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, January 11, 2005 2:12 pm, David Mosberger wrote:
> This seems wrong to me.  pgprot_writecombine() should do what it says,
> no more and no less.
>
> The EFI memory-map has already all the info needed to determine
> whether write-combine mapping is supported, so perhaps the code should
> be changed to take that into consideration instead?

But what about places that unconditionally set the WC bit regardless of what 
the EFI memory map says?  pci_mmap_page_range does this for example if the 
write_combine flag is set on the vma.  I'm looking for a way to abstract out 
uses like that, so that shub 1.x systems don't set the bit.

Jesse
