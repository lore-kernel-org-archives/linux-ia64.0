From: Andrew Morton <akpm@osdl.org>
Date: Tue, 22 Feb 2005 19:25:13 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <20050222112513.4162860d.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	<20050222020309.4289504c.akpm@osdl.org>
	<yq0ekf8lksf.fsf@jaguar.mkp.net>
	<20050222175225.GK28741@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050222175225.GK28741@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: jes@wildopensource.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Matthew Wilcox <matthew@wil.cx> wrote:
>
> On Tue, Feb 22, 2005 at 09:41:04AM -0500, Jes Sorensen wrote:
>  > >> + if (page->flags & PG_uncached)
>  > 
>  > Andrew> dude.  That ain't gonna work ;)
>  > 
>  > Pardon my lack of clue, but why not?

	if (page->flags & (1<<PG_uncached))

would have been correcter.

>  I think you're supposed to always use test_bit() to check page flags

Yup.  Add PageUncached macros to page-flags.h.
