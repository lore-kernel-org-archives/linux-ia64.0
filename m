From: "David S. Miller" <davem@davemloft.net>
Date: Sun, 20 Mar 2005 00:27:29 +0000
Subject: Re: [patch] arch hook for notifying changes in PTE protections bits
Message-Id: <20050319162729.12d6789d.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB75064943033468DE@scsmsx401.amr.corp.intel.com>
	<16956.35789.229286.442052@napali.hpl.hp.com>
In-Reply-To: <16956.35789.229286.442052@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: davidm@napali.hpl.hp.com, rohit.seth@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, 19 Mar 2005 12:30:05 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> I agree about your concern about cost.  Accessing the page_map is
> expensive (integer division + memory access) and we have to do that in
> order to find out if the page is i-cache clean.

First, it's a multiply by reciprocol.  At least on sparc64 I get
this emitted by the compiler.

Secondly, if you're willing to sacrifice 8 bytes per page struct
simply define WANT_PAGE_VIRTUAL and page struct will be exactly
64 bytes and thus the divide a will turn into a simple shift.
