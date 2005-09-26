From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 26 Sep 2005 20:40:36 +0000
Subject: RE: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F047E8E6D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This patchset differs very little from V3. It requires SPARSEMEM EXTREME
>patches which are in 2.6.14-rcX.

Bob,

Can you provide a bit more of a write up on what this change means?
Which config options have gone, what the new ones, and what are the
rules that determine what's legal.  The help options in Kconfig don't
seem very helpful here.

I think it would be a good idea to bundle a set of changes to the
default config files along with this change ... which means we should
have a discussion on what are the sensible defaults out of the new
array of options, and which of the non-default options are still
popular enough that I should make sure to test build them in my
regular scripts.  Right now this whole change is a close to being
a no-op as none of the default configs enables SPARSEMEM.

So can you throw together a straw-man proposal for each of the
default configs (maybe SGI can provide the sn2 version)?  I'm assuming
here that SPARSEMEM is going to be the preferred choice for some
system(s) ... I'm just not sure which.

-Tony
