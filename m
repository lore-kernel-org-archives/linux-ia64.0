From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Feb 2005 00:44:44 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E2BE02@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>It just went bang, saying that "f6" was corrupted ... but I'm
>not doing the right things to tickle the corner case on a regular
>basis ... so I only have the one data point so far.

Hmmm ... I'm not seeing anyplace where f6 is saved in the MCA path
before we call up to ia64_mca_ucmc_handler() ... which is bad as
f6 is designated as a scratch register.

-Tony
