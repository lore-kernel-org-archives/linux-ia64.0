From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 24 Jun 2005 21:05:00 +0000
Subject: RE: [patch] Memory Error Handling Improvement
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03C68979@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>will not help at all.  Furthermore, if MCA delivery timing changes for
>some reason, the user-triggered MCA might show up much later, i.e.,
>pretty much anywhere in the kernel no?

Not really.  Suppose there is some location in memory that has a multi-bit
ECC error, and the user reads this location:

	ld8 r17=[r18]

Now the MCA mechanism is asynchronous ... so nothing may happen right away,
but there is a guarantee that at the very latest the MCA will be delivered
before the poisoned data is consumed.  So suppose that we happen to try to
enter the kernel for some reason before the MCA is delivered.  Since the
kernel saves all the users registers, it will attempt to consume the data,
and so the MCA will be delivered.

For the user-mode MCA to survive to an arbitrary point in the kernel would
mean that we didn't save some user mode register.

-Tony
