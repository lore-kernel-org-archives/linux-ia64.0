From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Sun, 04 Jul 2004 07:13:43 +0000
Subject: Re: [patch] Fix ia64 UPF_RESOURCES pcdp.c 2.6.7-mm5 build
Message-Id: <20040704081342.A29091@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040704021907.32029.98969.47514@sam.engr.sgi.com>
In-Reply-To: <20040704021907.32029.98969.47514@sam.engr.sgi.com>; from pj@sgi.com on Sat, Jul 03, 2004 at 07:19:06PM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, David Mosberger <davidm@hpl.hp.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, bjorn.helgaas@hp.com, Matt Tolentino <matthew.e.tolentino@intel.com>

On Sat, Jul 03, 2004 at 07:19:06PM -0700, Paul Jackson wrote:
> It looks like someone removed UPF_RESOURCES in remove-upf_resources.patch
> in parallel with someone adding drivers/firmware/pcdp.c that references
> UPF_RESOURCES.

Your patch is correct.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
