From: Andi Kleen <ak@suse.de>
Date: Mon, 18 Oct 2004 19:06:51 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <20041018210651.66c3ab44.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net>
	<20041014180427.GA7973@wotan.suse.de>
	<yq1ekjvrjd6.fsf@wilson.mkp.net>
	<20041018184210.GI16153@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041018184210.GI16153@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: mkp@wildopensource.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

On Mon, 18 Oct 2004 19:42:10 +0100
Matthew Wilcox <matthew@wil.cx> wrote:

> I disagree with Andi over the dumbness
> of zeroing the whole page.  That makes it cache-hot, which is what you
> want from a page you allocate from slab.

Not for a page table, which tends to be not fully used.
It would be true for a user page, but that doesn't use this mechanism anyways.

-Andi
