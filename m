From: John Keller <jpk@sgi.com>
Date: Sun, 15 Jan 2006 17:43:29 +0000
Subject: Re: [PATCH] SN: Add initial ACPI support
Message-Id: <200601151743.k0FHhUUD381039@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0slrp1xg1.fsf@jaguar.mkp.net>
In-Reply-To: <yq0slrp1xg1.fsf@jaguar.mkp.net> from "Jes Sorensen" at Jan 15, 2006 07:34:54 AM
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@trained-monkey.org>
Cc: kaos@sgi.com, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

> 
> >>>>> "Keith" = Keith Owens <kaos@sgi.com> writes:
> 
> Hi,
> 
> Just a general comment on top of Keith's.
> 
> Keith> John Keller (on Sat, 14 Jan 2006 11:37:47 -0600 (CST)) wrote:
> >> +inline uint64_t +sal_ioif_init(void)
> 
> Keith> Make that static with no inline, let gcc decide if it should be
> Keith> inlined or not.
> 
> Please stick to using the preferred kernel internal types, u64/u32/u16
> etc. I noticed you switch u64 to uint64_t in many places which is the
> wrong way to go.

Agreed.
As mentioned earlier, I mistakenly posted an old version of the patch.



> 
> Regards,
> Jes
> 

