From: Robin Holt <holt@sgi.com>
Date: Thu, 03 Feb 2005 17:31:55 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <20050203173155.GC26062@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 03, 2005 at 09:55:26AM -0500, Jes Sorensen wrote:
> Is this because the applications will normally allocate their fetchops
> in the main thread before spawning off the threads? If the mmap is
> done by the thread that will 'own' the individual fetchop this
> wouldn't be a problem? Sorry, just trying to understand the nature of
> how these applications work, my knowledge of MPI etc. is ehm
> ... limited ;)

That is the normal way of doing things.  Nearly all large applications
have been operating under that assumption for a very long time
and changing all those apps to do the mmap after spawning workers
is unlikely.

Robin
