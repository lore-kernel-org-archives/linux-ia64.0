From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 26 Aug 2003 21:58:21 +0000
Subject: Re: [PATCH] ia64 oprofile support for 2.6.0-test4
Message-Id: <marc-linux-ia64-106193733214938@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106193081107734@msgid-missing>
In-Reply-To: <marc-linux-ia64-106193081107734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 26 Aug 2003 17:19:14 -0400, Will Cohen <wcohen@redhat.com> said:

  Will> For OProfile it didn't make a difference, but for the
  Will> histograms it is wasteful. I didn't think about the impact on
  Will> the traditional histogram.

You can't just break existing data formats for absolutely no reason.

  Will> Do the histogram analysis tools currently handle

Yes.  For example, I use "readprofile -b" from time to time to get
instruction-level histograms.

  Will> the fiction of bundle instruction 0 at address ending in 0,
  Will> bundle instruction 1 ending in 4, and bundle instruction 2 in
  Will> 8? GDB doesn't.

And encoding the slot number in bits 0 and 1 is somehow less
fictitious? ;-)

	--david
