From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 18 Jun 2004 14:37:18 +0000
Subject: Re: sys_ioctl export
Message-Id: <20040618143718.GA21206@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Just put the export into common code and guard it by CONFIG_COMPAT, matches
> > exactly the intended users.
> 
> Like this totally untested and uncompiled patch?

Looks good.  Maybe a small comment?

