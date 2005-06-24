From: "Luck, Tony" <tony.luck@Intel.com>
Date: Fri, 24 Jun 2005 21:31:28 +0000
Subject: RE: [patch] Memory Error Handling Improvement
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03C689E8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Fine, but what about my suggestion of just presuming that the access
>came for user-level unless you can prove otherwise?

If the presumption is wrong, then you'll kill an innocent user process.
Worse, you will let a corrupted kernel carry on running.

-Tony
