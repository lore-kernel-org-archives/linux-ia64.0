From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 05 Jan 2005 11:35:18 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20050105113518.GB31285@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 20, 2004 at 12:45:48PM -0600, Dean Nelson wrote:
> Having the XP module separate from XPC allows for XPC to come and go
> as needed without disturbing XPMEM and its users. This allows a site to
> run a particular partition in isolation for a time (XPC not loaded) and
> then open it up to the other partitions (XPC loaded).
> 
> In light of the above I would like to keep XP and XPC as separate modules.

I still think it's a bad idea, but I'm fed up with this discussion so go
ahead.

