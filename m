From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Mar 2006 20:58:40 +0000
Subject: RE: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06176548@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Tiger still boots with my release tree (just has seven patches that
> haven't been sent to Linus yet, including Russ' fix for my merge
> goof that created item "3" above).  I haven't pulled in from Linus
>in about three days, so I'm about 458 commits behind the bleeding
> edge.  So a "git bisect" between Linus head and the point where I last
> merged (commit 64bc0430) might yield the problem (for Ken's tiger
> boot issue).

Just started the bisection ... and the current tip of Linus' git
tree (f3cab8a0) booted just fine on tiger!  There are 85 commits
in there since git-17 was cut, but a quick glance at gitk doesn't
show any obvious fixes or reverts that might affect ia64.

-Tony
