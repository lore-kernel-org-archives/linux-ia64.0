From: Mike Kravetz <kravetz@us.ibm.com>
Date: Thu, 11 Aug 2005 21:14:19 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-Id: <20050811211419.GB5213@w-mikek2.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com> <20050809211501.GB6235@w-mikek2.ibm.com> <Pine.LNX.4.62.0508111343300.19728@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0508111343300.19728@graphe.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <christoph@lameter.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Thu, Aug 11, 2005 at 01:46:22PM -0700, Christoph Lameter wrote:
> > I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
> > max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
> > noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
> > someone tell me what the differences are between __pa() and virt_to_phys().
> > I noticed that on some archs they are the same, but are different on
> > others.
> 
> On which arches do they differ?

In alphabetical order I first looked at alpha and things didn't look
the same in the '#ifndef USE_48_BIT_KSEG' case.  When I first looked
at this, I quit after looking at alpha.  However, I can't seem to easily
find other archs that differ.

-- 
Mike
