From: Andi Kleen <ak@suse.de>
Date: Fri, 15 Oct 2004 01:18:38 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <20041015011838.GC9753@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net> <20041014180427.GA7973@wotan.suse.de> <Pine.LNX.4.58.0410141836270.1221@gradall.private.brainfood.com>
In-Reply-To: <Pine.LNX.4.58.0410141836270.1221@gradall.private.brainfood.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adam Heath <doogie@debian.org>
Cc: Andi Kleen <ak@suse.de>, "Martin K. Petersen" <mkp@wildopensource.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

On Thu, Oct 14, 2004 at 06:36:47PM -0500, Adam Heath wrote:
> On Thu, 14 Oct 2004, Andi Kleen wrote:
> 
> > Also that's pretty dumb. How about keeping track how much of the
> > page got non zeroed (e.g. by using a few free words in struct page
> > for a coarse grained dirty bitmap)
> >
> > Then you could memset on free only the parts that got actually
> > changed, and never waste cache lines for anything else.
> 
> That will fail when a struct is placed in the page, and only the beginning and
> end of the struct was changed.

Hmm? I think you're misunderstanding me. The dirty bitmap would cover 
all areas that are potentially not zero. If someone changes a byte
without setting the bitmap they're buggy. 


-Andi
> 
