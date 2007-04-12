From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 12 Apr 2007 21:13:34 +0000
Subject: Re: [KJ][PATCH 02/03]ROUND_UP|DOWN macro cleanup in arch/ia64,x86_64
Message-Id: <20070412211334.GA5892@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070412203140.GB9353@arun.site>
In-Reply-To: <20070412203140.GB9353@arun.site>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Milind Arun Choudhary <milindchoudhary@gmail.com>
Cc: kernel-janitors@lists.osdl.org, linux-ia64@vger.kernel.org, discuss@x86-64.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de

On Fri, Apr 13, 2007 at 02:01:40AM +0530, Milind Arun Choudhary wrote:
> -	size = ROUNDUP(size, iovp_size);
> +	size = ALIGN(size, iovp_size);

Why is "ALIGN" better than "ROUNDUP"?  I can't see any point
to this change.

-Tony
