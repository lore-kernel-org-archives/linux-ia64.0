From: Robin Holt <holt@sgi.com>
Date: Wed, 05 Mar 2008 09:53:52 +0000
Subject: Re: Interval timer
Message-Id: <20080305095352.GB2013@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080305094128.GA30069@cse.unsw.EDU.AU>
In-Reply-To: <20080305094128.GA30069@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 05, 2008 at 08:41:28PM +1100, Matthew Chapman wrote:
> Is there any interval timer on HP zx1 platforms, other than the
> CPU-based ITC/ITM?

How fine grained do you need?  How much jitter are you willing to
tolerate?  How much multiplexing are we talking about?

Robin
