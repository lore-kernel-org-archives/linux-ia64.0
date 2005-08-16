From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 16 Aug 2005 21:21:11 +0000
Subject: RE: [PATCH] Make sched_clock() work in early boot
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04294516@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816195916.GA753838@dragonfly.engr.sgi.com>
In-Reply-To: <20050816195916.GA753838@dragonfly.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I don't necessarily disagree.  Using a speculative load for this seemed
>a little sleazy to me.  I just didn't know of any other cheap way to
>test for the existence of the per-cpu area...

Perhaps look to see if ar.k3 has been set up with the physical
address of the per-cpu area?  You'd need to clear it early in
head.S (as I'm not sure what garbage it might contain) and delay
the initialization in cpu_init() until after the per-cpu area is
fully set up [which might create new challenges :-)].

-Tony
