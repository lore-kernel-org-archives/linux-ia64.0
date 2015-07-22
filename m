From: Paolo Bonzini <pbonzini@redhat.com>
Date: Wed, 22 Jul 2015 11:31:52 +0000
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
Message-Id: <55AF7F28.2020504@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>



On 21/07/2015 15:55, Vlastimil Babka wrote:
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index 2d73807..a8723a8 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -3158,7 +3158,7 @@ static struct vmcs *alloc_vmcs_cpu(int cpu)
>  	struct page *pages;
>  	struct vmcs *vmcs;
>  
> -	pages = alloc_pages_exact_node(node, GFP_KERNEL, vmcs_config.order);
> +	pages = alloc_pages_prefer_node(node, GFP_KERNEL, vmcs_config.order);
>  	if (!pages)
>  		return NULL;
>  	vmcs = page_address(pages);

Even though there's a pretty strong preference for the "right" node,
things can work if the node is the wrong one.  The order is always zero
in practice, so the allocation should succeed.

Paolo
