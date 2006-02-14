From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Feb 2006 16:56:23 +0000
Subject: RE: git question
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05B4FCCB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq08xsez26a.fsf@jaguar.mkp.net>
In-Reply-To: <yq08xsez26a.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes> first: git-clone
Jes> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
Jes> then: [jes@tomahawk linux-2.6]$ git-pull fatal: Needed a single
Jes> revision Pulling into a black hole?

Jes> Matthew suggested that I use git: of rsync: and strangely enough that
Jes> works. Baffling, but hey, I now have what I wanted ;)

I'm not sure what happened.  I did swap-out my links to the packfiles in
Linus' tree ... but I ran the "git prune" and "git-update-server-info"
afterwards.  So the tree should have been consistent (but possibly might
have had some objects in the packfiles that might not have been needed
by the heads in my tree if Linus was ahead of my tree).

In general the "rsync:" protocol should be the lowest overhead for a
fresh clone, but "git:" should be better for subsequent pulls and fetches.

-Tony
