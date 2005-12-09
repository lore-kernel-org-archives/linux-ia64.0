From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Dec 2005 18:38:16 +0000
Subject: RE: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F052A422B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> What if we added wrappers to the existing initcall functions to accept another 
> argument?
> 
> Instead of subsys_initcall(fn) we would do
> 
> subarch_subsys_initcall (fn, arch) and this wrapper would do a platform check of 
> the machine vector info?

That looks like a plausible direction to investigate.  Does anyone know
whether any other architectures have a similar problem that can be solved
in this way?  Or is ia64 the only one with a "generic" kernel that has to
work on such a diverse spread of machines?

Prarit: when you get further with this you'll need to post to linux-kernel
as well as linux-ia64 since this will touch generic code.

-Tony
