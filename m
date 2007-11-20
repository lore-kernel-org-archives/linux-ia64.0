From: Simon Horman <horms@verge.net.au>
Date: Tue, 20 Nov 2007 07:41:33 +0000
Subject: Re: [PATCH 01/59] arch/ia64: Add missing "space"
Message-Id: <20071120074132.GA3402@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1195523331-15303-1-git-send-email-joe@perches.com> <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com> <20071120065431.GC10490@verge.net.au> <1195542565.4675.104.camel@localhost>
In-Reply-To: <1195542565.4675.104.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, linux-altix@sgi.com, linux-ia64@vger.kernel.org

On Mon, Nov 19, 2007 at 11:09:25PM -0800, Joe Perches wrote:
> On Tue, 2007-11-20 at 15:54 +0900, Simon Horman wrote:
> > Is it really neccessary for this fragment to create a line that
> > is greater than 80 characters long? Persumably the entire reason
> > that the printk line was split in the first place was to avoid
> > a long line.
> 
> No.  Many other lines in that source file are > 80 char.

That may be so, but surely adding another one makes
things slightly worse.

> My initial preference was to reformat the indented lines to the
> printk open parenthesis, but the minimal change seemed better.
> 
> cheers, Joe

-- 
Horms

