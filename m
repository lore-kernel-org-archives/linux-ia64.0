From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Oct 2009 16:02:31 +0000
Subject: RE: ticket spinlocks and sizeof(struct dentry)
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E310D641@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091009021251.GA4287@wotan.suse.de>
In-Reply-To: <20091009021251.GA4287@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Just to let you know you may have turned sizeof(struct dentry) into
> something nasty with 64 bit spinlocks (like 200 bytes) which would
> mean a significant number (~half?) of dentries will cover 3 cachelines
> instead of 2.

Thanks for the heads-up ... Linus also pointed out this downside of
the current implementation.  IA64 uses 128 byte cache lines ... so your
calculation of how many we use for a dentry is off (we move from
exactly 1.5 cache lines to 1.5625 cache lines).  But this sucks too
because now the cache-line boundaries are scattered in different
places in different dentry instances, so all your careful work to
put stuff that is used together into the same cache line is randomly
broken on some dentry instances.

> If I'm nost mistaken, this would probably be worth correcting.

I'm working on it.

-Tony

