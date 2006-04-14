From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Apr 2006 17:43:01 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F063B58EB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Would it not be much simpler to use the SLIT table to estimate the 
> migration costs?

SLIT table doesn't account for HT and multicore effects.  Just node
to node distances.

-Tony
