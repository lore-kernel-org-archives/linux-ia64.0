From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 18 Feb 2004 17:08:58 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <20040218170858.A11064@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 18, 2004 at 10:33:29AM -0500, Robert Picco wrote:
> This PXM value (255) isn't a SLIT or PXM defined quantity.  It is really 
> specific to HP cell machines.  For example, a machine configured with 
> two cells will report three PXMs.  Two for the CPUs and one for the 
> interleaved memory at magic PXM 255.  The firmware doesn't report SLIT 
> information for PXM 255. The patch approximates the SLIT value for PXM 
> 255. I have attempted to arrive at code which doesn't break non-HP 
> hardware configurations. I have assumed the way the initialization code 
> was written that all NIDs require memory.  Otherwise 
> reserve_pernode_space will fail.

I know HP basically owns the IA64 ports, but honestly can't you fix
the firmware to return sane information instead?  i.e. move the above
fix to firmware instead of letting linux fixup the reported data.

