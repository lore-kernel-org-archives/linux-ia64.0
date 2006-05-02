From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 02 May 2006 21:33:17 +0000
Subject: RE: [RFC 2/3] LVHPT - Setup LVHPT
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06607EE1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ian Wienand <ianw@gelato.unsw.edu.au>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org

> Yes that does seem a bit miss-leading.  I guess the point was that
> with short format you dedicate the top areas of your region to page
> tables for each process, with long format it is static.

So perhaps adding the word "virtual" (in between the "lower" and the
"memory") into the help description, and dropping the bit "when there
are a large number of processes in the system" would be clearer?

-Tony
