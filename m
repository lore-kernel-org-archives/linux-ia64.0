From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 30 Jul 2004 22:15:35 +0000
Subject: RE: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01C02F48@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dean> The question is whether we export ia64_sal and sal_lock? Or change these
Dean> inline functions to no longer be inline, move them to a new file (sn_sal.c),
Dean> and export the individual function names?

Dean> From my point of view the first solution is better from the standpoint of
Dean> the diagnostics folks who write tests that need to make SAL calls. It doesn't
Dean> seem appropriate that the linux kernel be the repository of a bunch of ad hoc
Dean> and miscellaneous SAL wrapper functions that no one but the diagnostics folks
Dean> use.

Dean> I would like to know your opinions on the direction to go with this.

This looks like a lesser of two evils decision.  On balance I think
that I'd prefer not to open up the floodgates for modules to make
arbitrary SAL calls ... so I'd prefer to see you un-inline and
export the functions that you need. "sn_sal.c" sounds a plausible
name for a file to house these functions.

-Tony
