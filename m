From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 May 2008 20:42:18 +0000
Subject: Re: [PATCH 1/3] mm: Minor clean-up of page flags in mm/page_alloc.c
Message-Id: <alpine.LFD.1.10.0805161341140.2941@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080516192244.GD7885@sgi.com>
In-Reply-To: <20080516192244.GD7885@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>



On Fri, 16 May 2008, Russ Anderson wrote:
>
> Minor source code cleanup of page flags in mm/page_alloc.c.  
> Move the definition of the groups of bits to page-flags.h.

Ok, if you fix the comments (they are subtly wrong, probably due to 
excessive cut-and-paste), I can happily apply 1/3 regardless of any other 
issues.

		Linus
