From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 30 Apr 2004 20:09:22 +0000
Subject: RE: SAL PCI config space
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F011E705A@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>So what's actually shipping in systems?  David's against runtime checks
>due to some of the buggy firmware hp's managed to ship.  I agree with
>him that it would have been much more sensible had the SAL 
>spec specifid new calls rather than changing the semantics of existing
calls.

It's not whats shipping that's the big problem ... it's the people
still running BigSur, Lion and other prototype systems that will
never have their firmware upgraded to SAL3.2 spec.

Apart from general cleanliness of not having functions that are
re-entrant and MP safe uselessly spin on a lock to serialize, do
you see any tangible benefits from switching these to use the
SAL_CALL_REENTRANT method?  Surely config space accesses aren't
in anyone's critical path?

-Tony
