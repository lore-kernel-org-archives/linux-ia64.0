From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 22 Feb 2005 21:34:23 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <yq0acpwl1nk.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	<20050222020309.4289504c.akpm@osdl.org>
	<yq0ekf8lksf.fsf@jaguar.mkp.net>
	<20050222175225.GK28741@parcelfarce.linux.theplanet.co.uk>
	<20050222112513.4162860d.akpm@osdl.org>
In-Reply-To: <20050222112513.4162860d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Matthew Wilcox <matthew@wil.cx>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Andrew" = Andrew Morton <akpm@osdl.org> writes:

Andrew> Matthew Wilcox <matthew@wil.cx> wrote:
>> 
>> On Tue, Feb 22, 2005 at 09:41:04AM -0500, Jes Sorensen wrote:
>> > >> + if (page->flags & PG_uncached)
>> > 
>> > Andrew> dude.  That ain't gonna work ;)
>> > 
>> > Pardon my lack of clue, but why not?

Andrew> 	if (page->flags & (1<<PG_uncached))

Andrew> would have been correcter.

DOH!

Desperately seeking a bulk supply of those brown paper bags!

>> I think you're supposed to always use test_bit() to check page
>> flags

Andrew> Yup.  Add PageUncached macros to page-flags.h.

Mmmmm another butt ugly StUdLyCaPs macro coming soon.

Thanks,
Jes
