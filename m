From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 26 Oct 2004 23:53:48 +0000
Subject: RE: What does unwcheck.pl do?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0240BF55@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <523c02d87l.fsf@topspin.com>
In-Reply-To: <523c02d87l.fsf@topspin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Tony, below is a patch that fixes the unwind info enough that the
>warning/error goes away.  The unwind-info may not be 100% correct
>though.  Someone who can test/exercise this code may want to check on
>that.

I tried the patch ... but the error message is still there intermittently.
I saw it on the build for my zx2000 (zx1_defconfig with SMP=n), but not
for the tiger (tiger_defconfig).

-Tony
