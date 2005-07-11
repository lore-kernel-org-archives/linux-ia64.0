From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Jul 2005 18:21:09 +0000
Subject: RE: [PATCH 2.6.13-rc1 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03DF2628@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB6961.2060508@jp.fujitsu.com>
In-Reply-To: <42CB6961.2060508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>Why not be extra safe and call PAL_MC_FLUSH?  Or would that be too 
>expensive?

Just timed a call to PAL_MC_DRAIN (which is what I assume you meant).

Just over 13,000 cycles.

Is that too expensive?  How long does an i/o read take from a typical device?

-Tony
