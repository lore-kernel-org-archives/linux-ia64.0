From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Jan 2005 21:36:14 +0000
Subject: RE: new utility for decoding salinfo records
Message-Id: <16868.18126.166479.535592@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Jan 2005 13:23:48 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Whether it is a problem depends on the liklihood of it
  Tony> cascading into a multi-bit error ... for which I don't have
  Tony> any data.

While this is not an area I have experience with, it does seem to me
that considering how many clusters (really: "machines" with large
amounts of memory) are out there, there seems an amazing dearth of
solid data.  The memory manufacturers presumably have it, but are
disinterested in sharing.  On the other hand, I don't see any reason
why cluster operators (such as national labs) don't collect & share
such data more.  It's difficult for systems folks to make good choices
without such data, especially since the effects often appear to be
counter-intuitive (like SBEs not turning into MBEs).

	--david
