From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Feb 2008 18:41:18 +0000
Subject: RE: [PATH] Reduce per_cpu allocations to minimum needed for bootV3.
Message-Id: <1FE6DD409037234FAB833C420AA843EC8BEEA6@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080208225015.GK3875@sgi.com>
In-Reply-To: <20080208225015.GK3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Would you mind putting in the patch as it was with 32? 

I'll put in th V5 version that you just posted ... but this does
need some more cleanup.

For the hotplug path we should try to allocate both the per-cpu
area and the MCA stack space *before* we try to bring the cpu online
(i.e. allocation done by some existing cpu ... not by the cpu itself).

For the boot time path it is probably fine to just assume that
allocations will work (and panic if they don't).  Anyone that tries
to bring up 1024 cpus on a 512MB system deserves to see a panic :-)

-Tony
