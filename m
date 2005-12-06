From: Hugh Dickins <hugh@veritas.com>
Date: Tue, 06 Dec 2005 18:39:56 +0000
Subject: Re: [PATCH] /dev/mem validate mmap requests
Message-Id: <Pine.LNX.4.61.0512061832090.26899@goblin.wat.veritas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200512051700.20269.bjorn.helgaas@hp.com>
In-Reply-To: <200512051700.20269.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On Mon, 5 Dec 2005, Bjorn Helgaas wrote:
> Add a hook so architectures can validate /dev/mem mmap requests.

Not a comment on your patch at all, just an FYI in case you've missed
it, and in case it makes any difference to your ia64 needs.

A side-effect of 2.6.15-rc's PageReserved changes is that a user with
access to /dev/mem can now mmap any page of it, and see what's there
rather than zeroes, whether or not it has been marked PageReserved.

Hugh
