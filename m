From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 10 Nov 2003 17:56:39 +0000
Subject: Re: discontig patch question
Message-Id: <marc-linux-ia64-106848727429157@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106847971018555@msgid-missing>
In-Reply-To: <marc-linux-ia64-106847971018555@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 10, 2003 at 11:38:34AM -0600, Van Maren, Kevin wrote:
> > I wonder if that shouldn't be simply 1UL<<MAX_ORDER...  
> > That's all that
> > mm/page_alloc.c seems to care about.
> 
> But doesn't it deal with page-sized chunks?

Yeah, but 1UL<<MAX_ORDER will always be page aligned, right?

> It makes sense if all the memory chunks have to start on a "MAX_ORDER"
> boundary, but is that really the case?  That's pretty restrictive, at least
> with such a large MAX_ORDER.
> 
> Why is MAX_ORDER 19 on IA64?

For hugetlbfs, afaik.  But it should only be 18 according to
arch/ia64/Kconfig.

Jesse
