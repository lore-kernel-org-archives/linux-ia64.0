From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 14 Jul 2005 19:21:47 +0000
Subject: RE: Fix undefined reference to can_cpei_retarget for simulator build
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03E7443D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050714040909.GB15249@cse.unsw.EDU.AU>
In-Reply-To: <20050714040909.GB15249@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>> The simulator build doesn't turn on ACPI, so doesn't have a definition
>> of can_cpei_retarget.  Suggested patch attached.
>
>Sorry about that, never compiled for the simulator yet.
>
>You might want to send this with the Signed-off-by signature as specified
>in Documentation/SubmittingPatches.
>
>thanks for fixing this.

For a simple fix like this I'll *sometimes* put my name at the
head of the blame trail and commit it with just my "Signed-off-by"
(but still credit the real author).  I did it for this one, but
in general it is a whole lot faster/easier if people remember to
include their own sign off line.

-Tony
