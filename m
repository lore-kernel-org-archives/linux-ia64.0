From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Feb 2005 17:50:02 +0000
Subject: RE: [rfc] generic allocator and mspec driver
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02EA1A3E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Here's another version of the mspec driver with the generic
>allocator. I have tried to implement all the features we discussed on
>the list earlier, including marking pages as uncached using PG_arch_1
>and making /dev/mem honor it.

Did you see David's e-mail?  The one where he said:
>Note that PG_arch_1 is already being used as a "i-cache coherent" flag.

Won't bad things happen if someone tried to read a page from /dev/mem
that was marked PG_arch_1 by swiotlb code?

I'm also not thrilled about mem.c being cloned into arch/ia64.

-Tony

