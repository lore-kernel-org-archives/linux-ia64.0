From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 06 Apr 2007 17:29:03 +0000
Subject: RE: [PATCH] ia64: Fix CPU freq displayed in /proc/cpuinfo
Message-Id: <617E1C2C70743745A92448908E030B2A01535C08@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070406170449.GA21441@linux-os.sc.intel.com>
In-Reply-To: <20070406170449.GA21441@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


+		   "cpu MHz    : %lu.%03lu\n"
 		   "itc MHz    : %lu.%06lu\n"


Why did you cut the precision of cpu MHz back to 1Khz?  Is the
extra precision not-warranted, or is this just to be more like
other architectures?

Should we do the same for itc MHz to treat both evenly?

-Tony
