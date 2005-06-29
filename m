From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Jun 2005 18:42:55 +0000
Subject: RE: problem booting -mm2 kernel on rx2600
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03CDDA33@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506291236.14024.bjorn.helgaas@hp.com>
In-Reply-To: <200506291236.14024.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Tony Luck is also reporting that the latest GIT tree which includes
>> lots of stuff from the -mm kernel does not boot either on his zx2000.

To clarify, that's my GIT tree that isn't booting ... not Linus' tree.
My tree also has a bunch of patches that I pulled in from the ia64
mailing list.  I'm closing in on the problem patch using the
"git-rev-tree --bisect" method.

-Tony
