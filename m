From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 10 Mar 2005 13:49:22 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <yq0y8cvzk4d.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	<20050222020309.4289504c.akpm@osdl.org>
	<yq0ekf8lksf.fsf@jaguar.mkp.net>
	<20050222175225.GK28741@parcelfarce.linux.theplanet.co.uk>
	<20050222112513.4162860d.akpm@osdl.org>
	<yq0zmxwgqxr.fsf@jaguar.mkp.net>
	<20050222153456.502c3907.akpm@osdl.org>
	<yq0sm3negtb.fsf@jaguar.mkp.net>
	<20050223223404.GA21383@infradead.org>
	<yq0k6oydjjv.fsf@jaguar.mkp.net>
	<20050309225516.55195ddc.akpm@osdl.org>
In-Reply-To: <20050309225516.55195ddc.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: hch@infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Andrew" = Andrew Morton <akpm@osdl.org> writes:

Andrew> Jes Sorensen <jes@wildopensource.com> wrote:
>>  Convert /dev/mem read/write calls to use arch_translate_mem_ptr if
>> available. Needed on ia64 for pages converted fo uncached mappings
>> to avoid it being accessed in cached mode after the conversion
>> which can lead to memory corruption. Introduces PG_uncached page
>> flag for marking pages uncached.

Andrew> For some reason this patch still gives me the creeps.  Maybe
Andrew> it's because we lose a page flag for something so obscure.

Andrew> Nothing ever clears PG_uncached.  We'll end up with every page
Andrew> in the machine marked as being uncached.

Actually there's restrictions to how many pages are getting converted
as converting pages over from cached to uncached isn't trivial on ia64.

Andrew> But then, nothing ever sets PG_uncached, either.  Is there
Andrew> some patch which you're hiding from me?

Actually I posted that earlier, but it must have gotten lost in the
noise. It's part of the genalloc/mspec patchset. I'll send it to you
directly.

Andrew> If a page is marked uncached then it'll remain marked as
Andrew> uncached even after it's unmapped.  Or will it?  Would like to
Andrew> see the other patch, please.

Coming your way in a jiffy.

Andrew> We should add PG_uncached checks to the page allocator.  Is
Andrew> this OK?

I don't see any problems with that. The way it's meant to be used is
that once pages are converted over, they don't go back into the
allocator.

Cheers,
Jes
