From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 12 May 2006 19:18:40 +0000
Subject: RE: [IA64] rework memory attribute aliasing
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F067AEFB4@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605051719.50884.bjorn.helgaas@hp.com>
In-Reply-To: <200605051719.50884.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> If we were at -rc2, I'd just slide this right into Linus ... but we are
> a bit close to 2.6.17, so I'm polling for regression testing.  I don't
> want to find out that this breaks some other platform.

Silence ...

Well Andrew picked it up for -mm ... so I'm adding it to -test (meaning
that Andrew will drop his copy next time he pulls from me).

I also threw in the latest kexec to the -test tree ... it works for
me (on tiger).  Still needs some cleanup, but we can work with incremental
patches to fix specific issues from this point on.

-Tony
