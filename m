From: Robin Holt <holt@sgi.com>
Date: Thu, 03 Feb 2005 11:19:44 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <20050203111944.GA22664@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Jack> Ugly hack. Isn't there a better way? (I know this isn't your
> Jack> code & you probably don't like this either. I had hoped for a
> Jack> cleaner solution in 2.6....)
> 
> It's gross, ugly and I hate it ... not sure if there's a simpler way.
> Maybe we can use the same approach as the fbmem driver and do it all
> in the mmap() function, I will have to investigate that.

If you do it in the mmap, all the pages will be allocated and mapped
on the node doing the map.  This will result in large applications
using multiple threads to incur _LARGE_ amounts of numa traffic.
The first fault is critical for performance.

> 
> Jack> + /* + * Use the bte to ensure cache lines + * are actually
> Jack> pulled from the + * processor back to the md.  + */ +
> 
> Jack> This doesn't need to be done if the memory was being used for
> Jack> fetchops or uncached memory.
> 
> I'll check.

The bte zero is needed for memory mapped cached (one of the mechanisms
here) and also ensures the memory is zereod out when returned to the
memory pool.
