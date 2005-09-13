From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Sep 2005 21:19:09 +0000
Subject: RE: Is git broken?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F045EBA81@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509132003.j8DK3nTd2612486@efs.americas.sgi.com>
In-Reply-To: <200509132003.j8DK3nTd2612486@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I've just run git-update-server-info to build the indexes, so wait
>a few minutes for them to be mirrored and try the pull again.

If you have a recently pulled "linus" tree, then just copy/link the
two latest pack files from .git/objects/pack (they have names
that start with "pack-eceba347...") into .git/objects/pack in your
local copy of my tree.  That will save you pulling a 78MB file down
from kernel.org.

It is also possible that GIT is playing up.  I'm now using the
objects/info/alternates feature on kernel.org that should tell
GIT to look for anything it can't find in my tree in Linus' tree.

-Tony
