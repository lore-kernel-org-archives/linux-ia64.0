From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 23 Jun 2006 17:08:22 +0000
Subject: RE: patches added to release/test trees
Message-Id: <617E1C2C70743745A92448908E030B2A22FB2B@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> That makes sense.  But why is the ia64 git tree missing the Linus
> objects and tags in the first place?

"tags" is a bit ambiguous here, there are two possible things that
you might be talking about when you say "tag" w.r.t. a GIT tree.

1) A file in .git/refs/tags/ that contains the SHA1 of a git object.

2) A git object of type "tag".

The files in .git/refs/tags refer to GIT tag objects.  Usually a
tag object is a pointer to a commit object ... but they can point
at anything (the v2.6.11 tag object points to a "tree").

Things get more complex from here.  My kernel.org tree contains none
of the .git/refs/tags files (because I "git push" the heads of the
release/test branches up from my local tree, anf this won't copy any
tags files up ... even though they are all in my local tree from
my "git fetch linus" pulls from Linus).

The git tag objects actually are in my kernel.org tree!  But only
because I share packfiles with Linus to reduce load on kernel.org
mirroring system.

You don't get to see them though.  When you do a fetch/pull from
my tree (using "git://" transfer method), git will construct the
list of commit/tree/blob objects, build a packfile, and send it to
you.  Any tag objects in my (really Linus') packfile will just be
ignored.  If you used "rsync://", it would copy the whole packfile.
Not sure what an http:// pull would do.


Is that as clear as mud now?

-Tony
