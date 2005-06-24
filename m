From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Jun 2005 21:11:24 +0000
Subject: RE: [patch] Memory Error Handling Improvement
Message-Id: <17084.30460.517853.610660@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Jun 2005 14:05:00 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  >> will not help at all.  Furthermore, if MCA delivery timing changes for
  >> some reason, the user-triggered MCA might show up much later, i.e.,
  >> pretty much anywhere in the kernel no?

  Tony> Not really.  Suppose there is some location in memory that has a multi-bit
  Tony> ECC error, and the user reads this location:

  Tony> ld8 r17=[r18]

  Tony> Now the MCA mechanism is asynchronous ... so nothing may
  Tony> happen right away, but there is a guarantee that at the very
  Tony> latest the MCA will be delivered before the poisoned data is
  Tony> consumed.  So suppose that we happen to try to enter the
  Tony> kernel for some reason before the MCA is delivered.  Since the
  Tony> kernel saves all the users registers, it will attempt to
  Tony> consume the data, and so the MCA will be delivered.

Fine, but what about stores?

Furthermore, there are many ways to enter the kernel, so it still
makes no sense to me to consider external interrupts only.  System
calls for one are certainly quite common, too.

  Tony> For the user-mode MCA to survive to an arbitrary point in the
  Tony> kernel would mean that we didn't save some user mode register.

Again, what about stores?

	--david

