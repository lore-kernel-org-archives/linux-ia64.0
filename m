From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Mar 2005 18:33:25 +0000
Subject: Re: [Patch 1/3] Reclaim pmd and pte entries to quicklists.
Message-Id: <20050302183325.GA16702@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I wasn't suggesting to support multiple sizes, just to add a
> BUG_ON(size != PAGE_SIZE) or something like that.

What is the motivation for this?  I have not changed anything in the
pgtable allocation/free path which changes in any way the size.  I don't
see what issue I am raising with this patch.  The sizes are constants
defined in header files.  Can we just put in a #error instead?

I am just confused as to what we are trying to accomplish.

Thanks,
Robin
