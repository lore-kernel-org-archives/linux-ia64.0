From: Keith Owens <kaos@sgi.com>
Date: Wed, 18 May 2005 10:25:26 +0000
Subject: Re: Allocating uncacheable memory from OS
Message-Id: <9602.1116411926@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <11503.1116315459@kao2.melbourne.sgi.com>
In-Reply-To: <11503.1116315459@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 18 May 2005 04:15:03 -0400, 
Jes Sorensen <jes@wildopensource.com> wrote:
>>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
>
>>>>>> On Tue, 17 May 2005 17:37:39 +1000, Keith Owens <kaos@sgi.com> said:
>Keith> Is there any ia64 OS routine for allocating uncacheable memory?
>Keith> I am trying to simulate the SAL/OS interface for MCA handling
>Keith> and the min-state area is expected to be uncacheable.
>
>David> Jes Sorensen was/has been working on such a thing.
>
>Yep,
>
>I have something in the works, it used to be part of the mspec driver
>but I am in the process of pulling it out and making it a seperate
>entity.
>
>Currently the thing operates at page size entries only, is that
>sufficient for you Keith?

Page size allocations are exactly what I need.

