From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Feb 2008 23:10:25 +0000
Subject: RE: [PATH] Reduce per_cpu allocations to minimum needed for boot V3.
Message-Id: <1FE6DD409037234FAB833C420AA843EC8BE6DE@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080208225015.GK3875@sgi.com>
In-Reply-To: <20080208225015.GK3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This patch could be using the cpu_possible_map instead of our own.
> I was reluctant to do that, but there is nothing that prevents it.
> Does anybody have an opinion?

I hate to see duplication ... your new "early_cpu_possible_map" should
just end up with the same contents as "cpu_possible_map" ... won't it?

Is there some downside to using your new code to initialize the
existing cpu_possible_map?

-Tony
