From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 03 Feb 2005 14:55:26 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq0u0otpuap.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Robin" = Robin Holt <holt@sgi.com> writes:

Jack> Ugly hack. Isn't there a better way? (I know this isn't your
Jack> code & you probably don't like this either. I had hoped for a
Jack> cleaner solution in 2.6....)
>>  It's gross, ugly and I hate it ... not sure if there's a simpler
>> way.  Maybe we can use the same approach as the fbmem driver and do
>> it all in the mmap() function, I will have to investigate that.

Robin> If you do it in the mmap, all the pages will be allocated and
Robin> mapped on the node doing the map.  This will result in large
Robin> applications using multiple threads to incur _LARGE_ amounts of
Robin> numa traffic.  The first fault is critical for performance.

Robin,

Is this because the applications will normally allocate their fetchops
in the main thread before spawning off the threads? If the mmap is
done by the thread that will 'own' the individual fetchop this
wouldn't be a problem? Sorry, just trying to understand the nature of
how these applications work, my knowledge of MPI etc. is ehm
... limited ;)

Jack> + /* + * Use the bte to ensure cache lines + * are actually
Jack> pulled from the + * processor back to the md.  + */ +
>>
Jack> This doesn't need to be done if the memory was being used for
Jack> fetchops or uncached memory.
>>  I'll check.

Robin> The bte zero is needed for memory mapped cached (one of the
Robin> mechanisms here) and also ensures the memory is zereod out when
Robin> returned to the memory pool.

I already updated the  comment to state that we want the memory
zeroed in the pool.

Thanks,
Jes
