From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Dec 2004 17:44:09 +0000
Subject: RE: Anticipatory prefaulting in the page fault handler V1
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02844270@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, nickpiggin@yahoo.com.au
Cc: Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>If a fault occurred for page x and is then followed by page 
>x+1 then it may be reasonable to expect another page fault
>at x+2 in the future.

What if the application had used "madvise(start, len, MADV_RANDOM)"
to tell the kernel that this isn't "reasonable"?

-Tony
