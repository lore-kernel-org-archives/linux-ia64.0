From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 03 Feb 2005 07:47:43 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq07jlqqe3k.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jesse" = Jesse Barnes <jbarnes@engr.sgi.com> writes:

Jesse> On Wednesday, February 2, 2005 11:10 am, Jes Sorensen wrote:
>> The remaining issue I am facing is that for the uncached pool I
>> want to make it node aware and we want to use the spill pages from
>> the lower granules for this pool which is easily done on
>> SN2. However I see no generic way to get from a physical address to
>> node id for pages that do not have a struct page assigned to
>> them. I am curious if anyone has any suggestions for how to solve
>> this in a generic way?

Jesse> paddr_to_nid?

It's not clear to me this covers the spill memory found in the lower
granules and second it's really really slow, though that may not be a
real problem.

Cheers,
Jes
