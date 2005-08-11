From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 11 Aug 2005 22:37:35 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-Id: <Pine.LNX.4.62.0508111425070.20351@graphe.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
 <20050809211501.GB6235@w-mikek2.ibm.com> <Pine.LNX.4.62.0508111343300.19728@graphe.net>
 <20050811211419.GB5213@w-mikek2.ibm.com>
In-Reply-To: <20050811211419.GB5213@w-mikek2.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Thu, 11 Aug 2005, Mike Kravetz wrote:

> In alphabetical order I first looked at alpha and things didn't look the 
> same in the '#ifndef USE_48_BIT_KSEG' case.  When I first looked at 
> this, I quit after looking at alpha.  However, I can't seem to easily 
> find other archs that differ. -- Mike

Yes, the #ifndef USE_48_BIT_KSEG case is strange. Wonder what is going on 
there. Should _pa() not do the same?


