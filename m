From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Oct 2004 04:30:20 +0000
Subject: RE: more serious sparse-detected bug (with fix)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0221C63B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410041312.i94DCslZ030821@napali.hpl.hp.com>
In-Reply-To: <200410041312.i94DCslZ030821@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 	for (i = 4; i < 8; i++) {
>-		retval |= unw_access_gr(&info, i, &ppr->gr[i], &nat, 0);
>+		unsigned long val;
>+
>+		if (unw_access_gr(&info, i, &val, &nat, 0) < 0)
>+			return -EIO;
>+		retval |= __put_user(val, &ppr->gr[i]);
> 	}


Couldn't see why you added another local 'val' here as well as
the one declared at the top of the function ... so I dropped this
one.  Otherwise it *looks* good.  I've put it in my tree
(linux-ia64-release-2.6.9) which I'll push in a few minutes.

> trivially.  Patch below should fix the problem, but it's completely
> untested (I don't have any testcases for getregs/putregs).

I'd be happy to hear from anyone who does have some sort of test
exercising this before I ask Linus to pull.  The current crop of
bugs have shown how easy it is for the eyes to skip over typos
in this code.

-Tony
