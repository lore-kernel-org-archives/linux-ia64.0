From: Andrea Arcangeli <andrea@suse.de>
Date: Fri, 24 Dec 2004 18:31:28 +0000
Subject: Re: Increase page fault rate by prezeroing V1 [0/3]: Overview
Message-Id: <20041224183128.GI13747@dualathlon.random>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com> <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Luck, Tony" <tony.luck@intel.com>, Robin Holt <holt@sgi.com>, Adam Litke <agl@us.ibm.com>, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@vger.kernel.org, linux-kernel@vger.kernel.org

Did you notice I already implemented full PG_zero caching here with
prezeroing on top of it?

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.9/PG_zero-2
	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.9/PG_zero-2-no-zerolist-reserve-1

I was about to push this in SP1, but it was a bit late.
