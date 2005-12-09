From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Dec 2005 17:54:13 +0000
Subject: RE: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F052A40B6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'm not thrilled about this approach.
> 
> I'd *like* to be able to assume that "changes in arch/ia64/sn/* clearly
> don't affect non-SN platforms".  But this style breaks that.  Every ia64
> box calls all these SN init functions, and if somebody forgets the
> ia64_platform_is("sn2") check, bad things will happen.
> 
> I'd like it a whole lot better if all these initialization-type things
> could be hidden inside sn_setup() or some other machine vector.

Me too ... these ia64_platform_is("sn2") are getting sprinkled in
more and more places.

-Tony
