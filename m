From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 26 Jan 2006 21:05:11 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05892499@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I agree.  As changing that name would mean mixing what's essentially
> a coding style cleanup with a "meaty" change, how would you like me
> to proceed?
>
> As I mentioned earlier in this discussion, there are some changes
> needed in the area of mmiowb(), which is the primary user of this
> definition.  Perhaps such a change is best left for that effort?

I'll take "take 6" into the test tree (and onto Linus for 2.6.17).

Please don't forget to come back and do the cleanups.

-Tony
