From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 May 2006 23:02:08 +0000
Subject: RE: [IA64] rework memory attribute aliasing
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0673C7E6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605051719.50884.bjorn.helgaas@hp.com>
In-Reply-To: <200605051719.50884.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This closes a couple holes in our attribute aliasing avoidance scheme:

Looks good ... and adds some Documentation too: double bonus points :-)

Fixes the X issue on Intel Tiger platform, and your MCA with
Obsidian II problem: earns free replay :-)

If we were at -rc2, I'd just slide this right into Linus ... but we are
a bit close to 2.6.17, so I'm polling for regression testing.  I don't
want to find out that this breaks some other platform.

-Tony
