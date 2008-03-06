From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Mar 2008 21:56:29 +0000
Subject: RE: [PATCH] New way of storing MCA/INIT logs
Message-Id: <1FE6DD409037234FAB833C420AA843ECC0CB11@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Can you please provide some real MTBF data?

I don't have any data on MTBF rates in DIMMs.  There was a
study on single-bit ECC error rates in memory that IIRC
concluded that the rate was about 1 error per gigabyte per
two months.  This study was looking at errors caused by
high energy neutrons which came from the collision of
cosmic rays with the upper atmosphere.  Actual rates vary
by location because of the shape of the earths magnetic field,
and with altitude.

But that was a very old study ... newer DIMMs made on denser
silicon processes will most likely be more vulnerable to
neutron strikes.

-Tony
