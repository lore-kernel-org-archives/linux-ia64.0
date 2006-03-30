From: Grant Grundler <iod00d@hp.com>
Date: Thu, 30 Mar 2006 18:54:26 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <20060330185426.GE4839@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 30, 2006 at 09:16:11AM -0600, Jack Steiner wrote:
...
> The most recent kernel has changed this behavior so that the address will be
> referenced as uncached.
...
> NEW
>         acpi_os_map_memory() unconditionally calls ioremap() to do the
>         mapping
> 
>         ioremap
>                 if (efi_mem_attribute_range(offset, size, EFI_MEMORY_UC))
>                          return __ioremap(offset, size);

Could this be related to the issue of ioremap() vs ioremap_nocache()
that Mathew Wilcox proposed a patch for?

	http://lkml.org/lkml/2006/3/30/251

grant
