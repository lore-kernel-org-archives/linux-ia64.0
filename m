From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 20 Sep 2004 15:16:41 +0000
Subject: Re: [PATCH] arch/ia64/sn: SGI Altix hardware performance monitoring API
Message-Id: <20040920161641.A11929@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0409101641020.17255-100000@woolami.melbourne.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0409101641020.17255-100000@woolami.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 10, 2004 at 07:40:23PM +1000, Mark Goodwin wrote:
> On Fri, 10 Sep 2004, Christoph Hellwig wrote:
> > 
> > What tools are using this?  
> 
> Performance Co-Pilot http://oss.sgi.com/projects/pcp  in particular,
> pmshub, shubstats and linkstat. Numerous other users include anything
> that needs knowledge of numa topology/interconnect in order to perform
> well, e.g. mpt. BTW I have not exported any API functions .. at this
> point I don't think we need any modules to call the API.

Okay.

> > Might be worse to put an url to the source package into the Kconfig entry.
> 
> I don't quite grok "might be worse". But in any case, I can add something
> that's IA64_SGI_SN2 specific to arch/ia64/Kconfig if that is what you mean.

Sorry, silly typo.  Should have been "would be nice"
