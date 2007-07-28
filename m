From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 28 Jul 2007 06:15:51 +0000
Subject: Re: [PATCH] ia64: fix a few section mismatch warnings
Message-Id: <20070728061551.GA21626@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727074413.GA11424@uranus.ravnborg.org> <617E1C2C70743745A92448908E030B2A0209BADF@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0209BADF@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Fri, Jul 27, 2007 at 03:32:13PM -0700, Luck, Tony wrote:
> -		mca_data = alloc_bootmem(sizeof(struct ia64_mca_cpu)
> -					 * NR_CPUS + KERNEL_STACK_SIZE);
> +		mca_data = mca_bootmem(NR_CPUS + KERNEL_STACK_SIZE);
> 
> Oops.  You moved the multiply by sizeof(struct ia64_mca_cpu) up into
> the mca_bootmem() function to make it very specific to this use. But
> mutiply has higher precedence than addition.

Oh crap - good catch.
Shall I resubmit a corrected patch?

	Sam
