From: Christoph Hellwig <hch@lst.de>
Date: Mon, 06 Oct 2003 12:03:45 +0000
Subject: Re: [PATCH] more dead headers
Message-Id: <marc-linux-ia64-106544187026726@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106467172926098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106467172926098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Oct 05, 2003 at 12:41:03PM -0400, Jes Sorensen wrote:
> 
> FYI
> 
> fetchop.h and ioc4.h are for GPL'ed drivers that have already been
> published for 2.4 - they just need to be ported to 2.6. We can take
> them out now and stick them back in later if you prefer but doing so
> seems silly to me.

It's still the wrong place for them.  And the ioc4 driver including most
of the header is so utter junk that it needs a complete rewrite anyway.

