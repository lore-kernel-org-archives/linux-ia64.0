From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Mar 2009 18:39:24 +0000
Subject: RE: [GIT PULL] percpu, cpumask, x86 updates for v2.6.30
Message-Id: <57C9024A16AD2D4C97DC78E552063EA39B13FB2E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> If there was something here that shouldnt have happened then let me
> know and i'll trace back exactly how it happened and will prevent it
> in the future.

Then perhaps it was the sequence in which things were released to
Linus?  Jes & both saw a problem in the ia64 build after pulling
from Linus on Friday.  He came up with a patch, which I incorporated
& sent to Linus[1] ... and thus the conflict occurred when more stuff
came from your tree.

So bisectability was broken by the sequence of patches that were
being fed into Linus' tree.

-Tony

[1] Note this is the only patch that I've submitted so far for
2.6.30 ... I have some other stuff that has been sitting in
linux-next ... but some of it isn't as well aged there as it
should be, so I'm holding it back for the latter part of the
merge window to make sure I don't break anything that has
followed better aging practices.
