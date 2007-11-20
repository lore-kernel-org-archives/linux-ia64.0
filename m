From: Joe Perches <joe@perches.com>
Date: Tue, 20 Nov 2007 07:09:25 +0000
Subject: Re: [PATCH 01/59] arch/ia64: Add missing "space"
Message-Id: <1195542565.4675.104.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1195523331-15303-1-git-send-email-joe@perches.com>
	 <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
	 <20071120065431.GC10490@verge.net.au>
In-Reply-To: <20071120065431.GC10490@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: linux-kernel@vger.kernel.org, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, linux-altix@sgi.com, linux-ia64@vger.kernel.org

On Tue, 2007-11-20 at 15:54 +0900, Simon Horman wrote:
> Is it really neccessary for this fragment to create a line that
> is greater than 80 characters long? Persumably the entire reason
> that the printk line was split in the first place was to avoid
> a long line.

No.  Many other lines in that source file are > 80 char.

My initial preference was to reformat the indented lines to the
printk open parenthesis, but the minimal change seemed better.

cheers, Joe

