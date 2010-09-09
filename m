From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Sep 2010 20:10:38 +0000
Subject: RE: [PATCH] fix siglock
Message-Id: <987664A83D2D224EAE907B061CE93D53015DB60D43@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c8911a2302651c5f3@agluck-desktop.sc.intel.com>
In-Reply-To: <4c8911a2302651c5f3@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> But the system hung at 44 minutes :-(  I'm still pretty sure that
> this fsys.S path is the problem ... just need to see why my patch
> is still giving problems.

There were *two* places where fsys.S did an unlock, and I only fixed
one of them.  Running with a new patch (but I'll wait to see if this
one works before posting).

-Tony
