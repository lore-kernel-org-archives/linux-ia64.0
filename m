From: "Luck, Tony" <tony.luck@intel.com>
Date: Sun, 14 Nov 2004 20:07:10 +0000
Subject: RE: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0263128D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Can you remind me why k3?  Are you worried about the TR mapping the
>per-CPU region getting corrupted?

This isn't for correctness, or even efficiency (since this is a
very low frequency execution path).  It is just to make the code
easier to read and maintain.  The current code in the MCA path that
loops through the array of tlb info structures looking for the
one that matches the current cpus cr.lid is quite ugly.  Replicating
it in the INIT code to find the per-cpu save+stack area will add
to the ugliness.  Having the phys address of the per-cpu area in
ar.k3 would clean things up.

For the INIT case it would be safe to just "tpa" a per-cpu address,
but in the MCA case we shouldn't trust the TR mapping.

-Tony
