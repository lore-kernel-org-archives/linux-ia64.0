From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Thu, 05 Jan 2006 19:59:29 +0000
Subject: RE: Why is psr.ic off for ia64_pal_cache_flush?
Message-Id: <516F50407E01324991DD6D07B0531AD5902E7E@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD802C06B64@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD802C06B64@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Did you get any responses to this?  I played with ia64_pal_cache_flush
> on an Altix (over a year ago) and couldn't get it to work without
> converting it to use PAL_CALL.  Are you having a similar problem when
> you use it for XEN?

The PAL spec has changed so that PAL_CALL is correct and PAL_CALL_IC_OFF
is incorrect.  So this is a bug in Linux/ia64, though currently
harmless since ia64_pal_cache_flush is unused.

I think Kevin was going to submit a patch to the linux-ia64 list
so that others don't run into this problem in the future.

Dan

