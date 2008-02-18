From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 18 Feb 2008 12:30:52 +0000
Subject: Re: [PATCH 4/5] signal(ia64): add a signal stack overflow check
Message-Id: <20080218123052.GG21012@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <47B95D4F.8030003@cn.fujitsu.com>
In-Reply-To: <47B95D4F.8030003@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shi Weihua <shiwh@cn.fujitsu.com>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, Feb 18, 2008 at 06:26:23PM +0800, Shi Weihua wrote:
> +			if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
> +				new_rbs = (current->sas_ss_sp +
> +					  sizeof(long) - 1) & ~(sizeof(long) - 1);

I know you're only moving this code, but how about fixing it to use
ALIGN at the same time?

+			if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
+				new_rbs = ALIGN(current->sas_ss_sp,
+						sizeof(long));

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
