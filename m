From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 08 Sep 2003 18:31:27 +0000
Subject: Re: [PATCH] more discontig fun
Message-Id: <marc-linux-ia64-106304654020526@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942849830042@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942849830042@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 04, 2003 at 04:27:15PM -0700, David Mosberger wrote:
> >>>>> On Thu, 31 Jul 2003 13:28:57 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
> 
>   Jesse> Or would you like to see it cleaned up in some other way?
> 
> I'd like to see it done without changing the interface to efi_memmap_walk().

Rather than calling efi_memmap_walk(filter_rsvd_memory, ...), do you
think it would be ok to move the call into the leaf functions?  E.g.
count_pages would do a if(rsvd_memory(start, end)) return; instead of
getting called from filter_rsvd_memory()?  That would make it easier to
understand and also make it easier to pass the args around.

But maybe a more aggressive cleanup is called for?

Thanks,
Jesse
