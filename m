From: Robin Holt <holt@sgi.com>
Date: Tue, 15 Feb 2005 19:59:45 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050215195945.GF24401@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 15, 2005 at 11:46:21AM -0800, David Mosberger wrote:
> >>>>> On Tue, 15 Feb 2005 13:31:48 -0600, Robin Holt <holt@sgi.com> said:
> 
>   Robin> Is there a strong objection to implementing 4 levels of 16k
>   Robin> page tables for now and then, if someone else sees a need,
>   Robin> convert to using long page table format and adjust page
>   Robin> tables as needed at that point in time.
> 
> I certainly don't want to switch my machines to 4-levels.  There is
> zero need for that on the machines I use, so why pay the overhead of
> an extra level?

I missed the why the extra level question.  That part is motivated by
some large MPI jobs need a fourth level to get a large enough single
mapping to cover their entire dataset.  We have already tripped this
limitation for a couple of our really large customers.

Thanks,
Robin
