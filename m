From: Dean Roe <roe@sgi.com>
Date: Thu, 03 Feb 2005 17:31:19 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <200502031731.j13HVJHE089677@shaft.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> >>>>> "Robin" = Robin Holt <holt@sgi.com> writes:
> 
> Jack> Ugly hack. Isn't there a better way? (I know this isn't your
> Jack> code & you probably don't like this either. I had hoped for a
> Jack> cleaner solution in 2.6....)
> >>  It's gross, ugly and I hate it ... not sure if there's a simpler
> >> way.  Maybe we can use the same approach as the fbmem driver and do
> >> it all in the mmap() function, I will have to investigate that.
> 
> Robin> If you do it in the mmap, all the pages will be allocated and
> Robin> mapped on the node doing the map.  This will result in large
> Robin> applications using multiple threads to incur _LARGE_ amounts of
> Robin> numa traffic.  The first fault is critical for performance.
> 
> Robin,
> 
> Is this because the applications will normally allocate their fetchops
> in the main thread before spawning off the threads? If the mmap is
> done by the thread that will 'own' the individual fetchop this
> wouldn't be a problem? Sorry, just trying to understand the nature of
> how these applications work, my knowledge of MPI etc. is ehm
> ... limited ;)

You are correct.  The parent process mmaps one segment of fetchop
space and forks off all the worker processes.  The worker processes
inherit the fetchop mapping across the fork and each have their
portion of the segment they "own".  Now every process can read/write
every other process' fetchop area.

Dean

---
Dean Roe
Silicon Graphics, Inc.
roe@sgi.com
