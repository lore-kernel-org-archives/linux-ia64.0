From: Robin Holt <holt@sgi.com>
Date: Tue, 15 Feb 2005 19:49:42 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <20050215194942.GD24401@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 15, 2005 at 11:19:40AM -0800, David Mosberger wrote:
> >>>>> On Tue, 15 Feb 2005 13:11:20 -0600, Robin Holt <holt@sgi.com> said:
> 
>   Robin> We saw many silent data corruptions. The SN2 hardware will
>   Robin> give an MCA if both types of references are made by the cpu
>   Robin> at about the same time, but that depends on both transactions
>   Robin> being on the bus in close relationship to each other.
> 
> Yes, but the point is it affects _most_ of today's machines, including
> x86.  A while ago, there were some nasty data corruption issues on AMD
> chips caused by the AGP GART and the large mappings used by the Linux
> kernel, for example.

One thing I had not thought about before this is SN2 hardware will also
allow us to change the memory protections for the cachelines in the pages
of this granule to not allow cached references.  I am not sure if this
has been tested aside from design verification testing and probably some
of the offline diagnostic tests.

Would anybody have a concern with marking those cache lines as processor
uncached only?  Would there ever be a time that we would expect _ANY_
type of cached reference when the granule is being used for uncached
that would be an acceptable use?

Thanks,
Robin
