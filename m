From: Eric Desjardins <eric.desjardins@discreet.com>
Date: Thu, 10 Feb 2005 16:34:45 +0000
Subject: Re: Porting driver from x86
Message-Id: <1108053285.29380.22.camel@oshawa.rd.discreet.qc.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <1108041115.29380.6.camel@oshawa.rd.discreet.qc.ca>
In-Reply-To: <1108041115.29380.6.camel@oshawa.rd.discreet.qc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It's close source unfortunately.

Eric

On Thu, 2005-02-10 at 11:41, Matthew Wilcox wrote:
> On Thu, Feb 10, 2005 at 10:05:04AM -0500, Eric Desjardins wrote:
> > The drivers want's to know if it has been put to sleep or not. It's not
> > used often. It's not my code and the reasons seems a bit obscure to me.
> 
> Do you mean "wants to know if it can sleep or not"?  If so, checking like
> this isn't appropriate -- it should already know whether or not it can sleep.
> Where's the source to this driver?
-- 
Eric Desjardins <eric.desjardins@discreet.com>
