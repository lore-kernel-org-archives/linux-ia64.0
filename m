From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 23 Feb 2005 00:48:44 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <1109119724.7277.25.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	 <20050222020309.4289504c.akpm@osdl.org> <yq0ekf8lksf.fsf@jaguar.mkp.net>
	 <20050222175225.GK28741@parcelfarce.linux.theplanet.co.uk>
	 <20050222112513.4162860d.akpm@osdl.org>
	 <1109100938.25666.44.camel@localhost>  <yq0650kl1gd.fsf@jaguar.mkp.net>
In-Reply-To: <yq0650kl1gd.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@wildopensource.com>
Cc: Andrew Morton <akpm@osdl.org>, Matthew Wilcox <matthew@wil.cx>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 2005-02-22 at 16:38 -0500, Jes Sorensen wrote:
> >>>>> "Dave" = Dave Hansen <haveblue@us.ibm.com> writes:
> 
> Dave> I was talking with Nigel Cunningham about doing something a
> Dave> little different from the classic page flag bits when the number
> Dave> of users is restricted and performance isn't ultra-critical.
> Dave> Would something like this work for you, instead of using a real
> Dave> page->flags bit for PG_cached?
> 
> Just took a quick look at this and it looks a bit heavy for our
> use. We are only looking at a small number of pages. However I could
> imagine future cases where performance may be more critical.

If it's a quite small number (or range) of pages, perhaps a short
list_head list would suffice.  It would sure beat consuming a page flag.

-- Dave

