From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 30 Apr 2004 21:59:02 +0000
Subject: RE: SAL PCI config space
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F011E70B5@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Multiple OSs/executables on different Soft partitions do not share
>> others' lock variables, unless otherwise all SAL calls of soft
>> partitions are redirected to one hosting OS, which sounds not
>> reasonable.
>
>Yes. I think that's why the SAL spec changed because all the vendors
>want to support virtual machines.
>But that doesn't help the older boxes which do not implement
>the newer SAL spec or have "non-compliant" implementations.

There would be other issues besides whether some SAL calls
are re-entrant to running multiple OS in soft partitions. E.g.
MCA

-Tony
