From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Nov 2005 23:34:46 +0000
Subject: RE: [PATCH] - Make pfn_valid more precise for SGI Altix systems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04EADE32@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051109202506.GA4152@sgi.com>
In-Reply-To: <20051109202506.GA4152@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ignore earlier message ... I thought I saw a || when you really
just have && all the way through this:

+# define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))

Doesn't that mean that you are optimizing for the case where some
one passed in a bad pfn ... does that really happen a lot?

-Tony
