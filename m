From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 23 Jun 2004 06:21:04 +0000
Subject: Re: Is vfat fs case sensitive in 2.6.7?
Message-Id: <20040623062104.GA18703@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622224302.GA953@lucon.org>
In-Reply-To: <20040622224302.GA953@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 22, 2004 at 11:14:01PM -0700, H. J. Lu wrote:
> I have
> 
> CONFIG_NLS_DEFAULT="utf8"
> 
> in .config. Does it make a difference?

Yes, check recent lkml archives.

