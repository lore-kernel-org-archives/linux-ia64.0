From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 21 Dec 2005 19:32:20 +0000
Subject: Re: [PATCH 3/4] per-platform IA64_{FIRST,LAST}_DEVICE_VECTOR definitions
Message-Id: <20051221193220.GF2361@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051221184337.5003.85653.32527@attica.americas.sgi.com> <20051221184353.5003.87888.74327@attica.americas.sgi.com> <20051221190916.GE2361@parisc-linux.org> <20051221191843.GJ9920@sgi.com>
In-Reply-To: <20051221191843.GJ9920@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Wed, Dec 21, 2005 at 01:18:43PM -0600, Mark Maule wrote:
> Ok.  Was just following the lead of this:
> 
> static struct msi_desc* msi_desc[NR_IRQS] = { [0 ... NR_IRQS-1] = NULL };
> 
> So arrays are always init'd to zero?

Static variables without an initialiser go to the bss section and get
initialised to 0 by the loader.  So the initialisation above is
redundant on all machines which use a bitpattern of zeros to represent
the NULL pointer.  Which is all machines Linux runs on.
