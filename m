From: Adam Heath <doogie@debian.org>
Date: Thu, 14 Oct 2004 23:36:47 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <Pine.LNX.4.58.0410141836270.1221@gradall.private.brainfood.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net> <20041014180427.GA7973@wotan.suse.de>
In-Reply-To: <20041014180427.GA7973@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: "Martin K. Petersen" <mkp@wildopensource.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

On Thu, 14 Oct 2004, Andi Kleen wrote:

> Also that's pretty dumb. How about keeping track how much of the
> page got non zeroed (e.g. by using a few free words in struct page
> for a coarse grained dirty bitmap)
>
> Then you could memset on free only the parts that got actually
> changed, and never waste cache lines for anything else.

That will fail when a struct is placed in the page, and only the beginning and
end of the struct was changed.

