From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 20 Sep 2006 16:42:53 +0000
Subject: RE: [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
Message-Id: <617E1C2C70743745A92448908E030B2A8AF60B@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158288948.2591.195.camel@linux-znh>
In-Reply-To: <1158288948.2591.195.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Tony, Nan Hai, do you have any thoughts on merging this
> series into ia64 test? Its really far to big to be managed
> as a single unit. I would be much more comfortable if
> we could track small incremental changes. Even the diff
> between the current and previous version (as below) is quite large.

I'm open to suggestions.  My current inclination is to abandon the
existing kexec/kdump patches that are currently in my test tree[1] and
replace them with the latest set of patches.  So a re-diff of all that
is considered good against 2.6.18 would be ideal for that.

Breaking the patch into some smaller pieces would also be good,
but I don't think this needs to be taken to extremes (just define
a few basic areas and split the patch ... I don't thing it is
worth spending days/weeks to split this into a sequence  of 37 individually
crafted patches, with the kernel being fully functional at every
one of the 36 intermediate points).

-Tony

[1] My test tree is not a guaranteed monotonic increasing sequence of
changesets.  I've already blown it away once before to clean out all
the crufty "Auto-update from upstream" commits that my workflow generates.
It's due for another clean-up anyway.
