From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 09 Aug 2005 23:02:35 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-Id: <17145.13835.592008.577583@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, Mike Kravetz <kravetz@us.ibm.com>, "Luck, Tony" <tony.luck@intel.com>

>>>>> "Yasunori" = Yasunori Goto <y-goto@jp.fujitsu.com> writes:

Yasunori>     (Note: Mike Kravez-san's code was defined by MACRO like
Yasunori> this.  #ifndef MAX_DMA_PHYSADDR #if MAX_DMA_ADDRESS = ~0UL
Yasunori> : : However, MAX_DMA_ADDRESS is defined with cast "(unsigned
Yasunori> long)" in some architecture like i386. And, preprocessor
Yasunori> doesn't like this cast in #IF sentence and displays error
Yasunori> message as "missing binary operator befor token "long"".
Yasunori> So, I changed it to static inline function.)

Yasunori> +static inline unsigned long max_dma_physaddr(void) 
Yasunori> +{
Yasunori> + 
Yasunori> +  if (MAX_DMA_ADDRESS = ~0UL) 
Yasunori> +	return MAX_DMA_ADDRESS; 
Yasunori> +  else 
Yasunori> +	return __pa(MAX_DMA_ADDRESS); 
Yasunori> +} 

This code illustrates one of my pet coding-style hates:  there's no
need for the `else' as the return statement means it'll never be
reached.

	if (MAX_DMA_ADDRESS = ~0UL)
	    return MAX_DMA_ADDRESS;
	return __pa(MAX_DMA_ADDRESS);

is all that's needed.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
