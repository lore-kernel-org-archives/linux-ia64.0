From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Dec 2004 18:32:20 +0000
Subject: RE: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F028C1639@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, ak@suse.de

>this behavior is turned on by default only for IA64 NUMA systems

>A boot line parameter "hashdist" can be set to override the default
>behavior.


Note to node hot-plug developers ... if this patch goes in you
will also want to disable this behaviour, otherwaise all nodes
become non-removeable (unless you can transparently re-locate the
physical memory backing all these tables).

-Tony
