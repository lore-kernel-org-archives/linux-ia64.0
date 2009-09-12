From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 12 Sep 2009 23:24:37 +0000
Subject: RE: [RFC] Convert ia64 spinlocks to use "tickets"
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E0564BE4@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4aa9e16649286264@agluck-desktop.sc.intel.com>
In-Reply-To: <4aa9e16649286264@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Have you done any testing where the spin with interrupts disabled was
> problematic?

So far my testing has been limited to mild stress running kernel builds.
Any pointers to other stress tests that might shed light on these kinds
of problems would be gratefully received.  Presumably some sort of heavy
i/o (networking) benchmark so there are lots of interrupts to process?

> I know we have had ages of problems with these, but I don't recall
> any specific instances right now (keep in mind it is 3:00 AM when I am
> finally getting to look at this).

Thanks for looking at it.

-Tony
