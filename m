From: "Luck, Tony" <tony.luck@intel.com>
Date: Sun, 13 Nov 2005 00:35:12 +0000
Subject: RE: GIT maintenance on ia64 test tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04F1BAEF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04EE77E4@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04EE77E4@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As previously advertised ... my old test tree has been blown
away and replaced with a new one that isn't full of cruft.

If you pull from it to a tracking branch, then git/cogito
should complain loudly.  Fix this by making the tracking
branch be a copy of v2.6.15-rc1 by whatever means necessary.

Currently the test branch is empty (exactly equal to 2.6.15-rc1).
I'll start loading it up with 2.6.16 material next week.

-Tony
