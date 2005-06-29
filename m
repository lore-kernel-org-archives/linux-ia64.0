From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Jun 2005 19:53:49 +0000
Subject: RE: problem booting -mm2 kernel on rx2600
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03CDDB0F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506291236.14024.bjorn.helgaas@hp.com>
In-Reply-To: <200506291236.14024.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>To clarify, that's my GIT tree that isn't booting ... not Linus' tree.
>My tree also has a bunch of patches that I pulled in from the ia64
>mailing list.  I'm closing in on the problem patch using the
>"git-rev-list --bisect" method.

The binary search hit bottom on this http://tinyurl.com/ds425 changeset.
So it's unrelated to the problems that Stephane has with -mm tree.

Bjorn, Mark: any ideas why this is breaking zx2000?

-Tony
