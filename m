From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 02 Feb 2005 19:46:32 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <200502021146.32810.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, February 2, 2005 11:10 am, Jes Sorensen wrote:
> The remaining issue I am facing is that for the uncached pool I want to
> make it node aware and we want to use the spill pages from the lower
> granules for this pool which is easily done on SN2. However I see no
> generic way to get from a physical address to node id for pages that do
> not have a struct page assigned to them. I am curious if anyone has any
> suggestions for how to solve this in a generic way?

paddr_to_nid?

Jesse
