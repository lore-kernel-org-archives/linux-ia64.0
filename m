From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 03 Feb 2005 20:58:16 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq0pszhpdhz.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jack" = Jack Steiner <steiner@sgi.com> writes:

Jack> On Thu, Feb 03, 2005 at 03:38:45AM -0500, Jes Sorensen wrote:

Jack> sorry - I mised your reply. Apparantly, it looks like SPAM:

Urgh, Barracuda! No comment ;-(

Jack> On Wed, Feb 02, 2005 at 02:10:32PM -0500, Jes Sorensen wrote:
Jack> General comment:
>>  Jack, thanks for the comments, I'll look at it, however I have the
>> following comments (which may or may not be correct from my side):
>> 
Jack> 1) I may be paranoid, but I'm nervous about using memory visible
Jack> to the VM system for fetchops. If ANYTHING in the kernel makes a
Jack> reference to the memory and causes a TLB dropin to occur, then
Jack> we are exposed to data corruption. If memory being used for
Jack> fetchops is loaded into the cache, either directly or by
Jack> speculation, then data corruption of the uncached fetchop memory
Jack> can occur.

Jack> Am I being overly paranoid? How can we be certain that nothing
Jack> will ever reference the fetchop memory alocated from the general
Jack> VM pool. lcrash, for example.

Jack,

I hear your concerns! However, at the same time, if something within
the kernel starts mocking with memory it doesn't own, thats a bug.
Admittedly that can a royal pain in the b*tt to debug since a simple
load can trigger it.

I was more concerned that there would be a case where prefetching or
speculation would spill into a page in another granule and thereby
cause a cacheable operation on the memory. However I don't quite
understand the hardware to this level to be 110% sure.

>>  Once a page is handed out using alloc_pages, the kernel won't
>> touch it again unless you explicitly map it etc. or if some process
>> touches memory at random, which could also happen with the spill
>> pages.  So I don't think the situation is any worse than it is for
>> the spill pages in the lower granules.

Jack> In theory, you are correct & maybe I'm being overly
Jack> paranoid. However, a failure is almost impossible to debug.

I wonder if it's something one could run a test on by running all of
the kernel data memory outside the identity mapped area and then
read-protecting the pages handed to the uncached allocator. Would
require a fair bit of instrumentation though so I am not sure it would
be feasible to try out.

Jack> Using the UC area in the low granules seems safe but it still
Jack> took us a long time to get it right. The kernel is unaware of
Jack> the memory & with the exception of the fetchop code, nothing in
Jack> the kernel ever references the spill areas.

Jack> I can't find any specific place that will fail using kernel
Jack> memory for mspec but my gut feeling is that we are more exposed
Jack> to errors using memory the kernel knows about than in using the
Jack> spill areas.  For example, although I don't see any problems
Jack> here because of it's limited use, virt_addr_valid() &
Jack> pfn_valid() is FALSE for the spill area but TRUE for kernel
Jack> memory.

I added support for converting pages since it was my understanding
this was something there was a wish for. We can limit the uncached
allocator to just use the spill pages but then we're back in the exact
same situation we had with the old allocator there was in fetchop.c.

Jack> What prevents lcrash (or /dev/kmem or /proc/kcore) from
Jack> referencing special memory being used for fetchops? Granted,
Jack> this takes root privilege but the consequences of a bad
Jack> reference can cause silent data corruption that is impossible to
Jack> debug.  Should we add code to prohibit these area from
Jack> referencing granules being used for mspec memory?

I believe you will have the same problem with anyone messing with
/dev/mem at random on the spill pages. I can't see us doing anything
here besides saying that fetchop isn't supported if someone plays that
kinds of games on their system as root.

Jack> Forgive the paranoia but several of use spent a long time
Jack> debugging some of these issues. Maybe all I'm asking is that
Jack> everyone spend a little extra time thinking of ways that the
Jack> kernel could cause a TLB entry to be made to a granule being
Jack> used for mspec memory.

Perfectly reasonable, which is also why I posted it to the list. More
brains thinking about a problem are more likely to find any potential
caveats.

>>  I thought about this one a fair bit after reading your comments
>> and I don't think it's an issue. The pages in the kernel's cached
>> mapping are identity mapped which means we shouldn't see any tlbs
>> for this, which leaves us with just tlbs for pages that have
>> explicitly been mapped somewhere - user tlbs should be removed when
>> a process is shot down or pages unmapped and vfree() calls
>> flush_tlb_all(). Or, am I missing something?

Jack> Identity mapped memory still requires a TLB entry. Somewhere,
Jack> these entries need to be purged before using a newly allocated
Jack> granule for fetchops or uncached memory. Also, the TLB entries
Jack> need to be purged before the cache is flushed. And the cache
Jack> flushing can't require a cacheable TLB entry to be made.

Aha, I  wasn't aware of this, I thought the region registers worked
like some giant TLB. I'll add a flush for the granule when it's pulled
into the allocator.

Cheers,
Jes
