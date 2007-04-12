From: Andi Kleen <ak@suse.de>
Date: Thu, 12 Apr 2007 20:37:20 +0000
Subject: Re: [KJ][PATCH 03/03]ROUND_UP|DOWN macro cleanup in arch/ia64,x86_64
Message-Id: <200704122237.20779.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070412203205.GC9353@arun.site>
In-Reply-To: <20070412203205.GC9353@arun.site>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Milind Arun Choudhary <milindchoudhary@gmail.com>
Cc: kernel-janitors@lists.osdl.org, linux-ia64@vger.kernel.org, discuss@x86-64.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com

On Thursday 12 April 2007 22:32:05 Milind Arun Choudhary wrote:
> ROUND_UP macro cleanup in arch/x86_64
> ALIGN, ALIGN_DOWN  where ever appropriate.

Sorry, but I prefer round_up/round_down in x86-64 code.

-Andi
