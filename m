From: David Miller <davem@davemloft.net>
Date: Wed, 26 Mar 2008 00:16:49 +0000
Subject: Re: larger default page sizes...
Message-Id: <20080325.171649.223175755.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <18408.59112.945786.488350@cargo.ozlabs.ibm.com>
	<20080325.163240.102401706.davem@davemloft.net>
	<1FE6DD409037234FAB833C420AA843ECE9E2CA@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE9E2CA@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: paulus@samba.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org

From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 25 Mar 2008 16:49:23 -0700

> Making an application use huge pages as heap may be simple
> (just link with a different library to provide with a different
> version of malloc()) ... code, stack, mmap'd files are all
> a lot harder to do transparently.

The kernel should be able to do this transparently, at the
very least for the anonymous page case.  It should also
be able to handle just fine chips that provide multiple
page size support, as many do.
