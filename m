From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Sep 2005 20:58:15 +0000
Subject: RE: Is git broken?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F045EBA03@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509132003.j8DK3nTd2612486@efs.americas.sgi.com>
In-Reply-To: <200509132003.j8DK3nTd2612486@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mea culpa (I think)

I suspect I've missed one of the important steps in maintaining
a public repository ... which only matters if someone isn't up
to date with my tree when I update the list of packfiles and prune
away the objects that are now in the packfiles.  When you try to
pull using rsync, you can't find the files directly in the objects
directory, and because I hadn't made the index, you were stuck.

I've just run git-update-server-info to build the indexes, so wait
a few minutes for them to be mirrored and try the pull again.

I'll fix my push script to do this automatically so this doesn't
happen again.

-Tony

