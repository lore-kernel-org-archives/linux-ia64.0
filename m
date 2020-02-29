From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 29 Feb 2020 22:33:08 +0000
Subject: Re: [PATCH v3 4/7] x86/mm: Introduce _set_memory_prot()
Message-Id: <CAPcyv4j=bZ5KBPp6PbViERdDe+HZpV_W6qbSJupTNAzyfiK6xg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200221182503.28317-1-logang@deltatee.com>
 <20200221182503.28317-5-logang@deltatee.com>
In-Reply-To: <20200221182503.28317-5-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>
Cc: X86 ML <x86@kernel.org>, linux-ia64@vger.kernel.org, Linux-sh <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, platform-driver-x86@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>, linux-s390 <linux-s390@vger.kernel.org>, David Hildenbrand <david@redhat.com>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Eric Badger <ebadger@gigaio.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, Feb 21, 2020 at 10:25 AM Logan Gunthorpe <logang@deltatee.com> wrote:
>
> For use in the 32bit arch_add_memory() to set the pgprot type of the
> memory to add.
>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> ---
>  arch/x86/include/asm/set_memory.h | 1 +
>  arch/x86/mm/pat/set_memory.c      | 7 +++++++
>  2 files changed, 8 insertions(+)
>
> diff --git a/arch/x86/include/asm/set_memory.h b/arch/x86/include/asm/set_memory.h
> index 64c3dce374e5..0aca959cf9a4 100644
> --- a/arch/x86/include/asm/set_memory.h
> +++ b/arch/x86/include/asm/set_memory.h
> @@ -34,6 +34,7 @@
>   * The caller is required to take care of these.
>   */
>
> +int _set_memory_prot(unsigned long addr, int numpages, pgprot_t prot);

I wonder if this should be separated from the naming convention of the
other routines because this is only an internal helper for code paths
where the prot was established by an upper layer. For example, I
expect that the kernel does not want new usages to make the mistake of
calling:

   _set_memory_prot(..., pgprot_writecombine(pgprot))

...instead of

    _set_memory_wc()

I'm thinking just a double underscore rename (__set_memory_prot) and a
kerneldoc comment for that  pointing people to use the direct
_set_memory_<cachemode> helpers.

With that you can add:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
