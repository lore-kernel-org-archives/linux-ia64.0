From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 11 Aug 2005 20:46:22 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-Id: <Pine.LNX.4.62.0508111343300.19728@graphe.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
 <20050809211501.GB6235@w-mikek2.ibm.com>
In-Reply-To: <20050809211501.GB6235@w-mikek2.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Tue, 9 Aug 2005, Mike Kravetz wrote:

> I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
> max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
> noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
> someone tell me what the differences are between __pa() and virt_to_phys().
> I noticed that on some archs they are the same, but are different on
> others.

On which arches do they differ?

