From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Mar 2005 21:57:49 +0000
Subject: RE: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03037481@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Here are the changes again.  I have not received a response from you
>about the restructered shrink routine.  I have incorporated David
>Mosberger's recommendations.

Your new shrink routine looks ok, but you didn't address the
double role played by NODE_FREE_PAGES_SHIFT ... you just dropped the
comment that explained one of its uses - which isn't what I'd hoped
for :-)

I'm also a bit uncomfortable with:

+		preempt_enable();
+		preempt_disable();

For a kernel with CONFIG_PREEMPT=n, this is a no-op ... so if there
is a ton of extra pages on the quicklist, we'll loop freeing 16 at
a time and re-computing how many to free, with no pause to take a
breath (or a clock tick).

Are there other places in the kernel where this idiom is being used?

-Tony

