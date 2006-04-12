From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 12 Apr 2006 17:22:17 +0000
Subject: RE: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <4sur0l$m2qgh@fmsmga001.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Wednesday, April 12, 2006 12:19 AM
> Does the attached seem like the right direction?  I have tested it on
> the simulator and it seems _much_ faster, but that is the simulator.
> I have time reserved on the machine where the problem was first observed
> later today to test it on actual hardware.

Very nice!


> +		next_page_offset = ALIGN(end_address, sizeof(struct page));

ALIGN only works on power of 2 alignment, I think you would get very
unpleasant rounding with the above.

- Ken
