From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Apr 2004 21:48:38 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <16526.54582.528367.407390@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 Apr 2004 16:31:57 -0500, Jack Steiner <steiner@sgi.com> said:

  Jack> Maybe I was not clear. I *know* that memory attribute aliasing
  Jack> is a bad thing to do. I was commenting on Robin's mail and
  Jack> providing a real-life example on where/how it causes
  Jack> problems. Prefetching is a perfectly valid thing for the cpu
  Jack> to do. Any time there is a valid TLB entry, prefetching can &
  Jack> will happen. DONT allow a TLB entry to cover both cached &
  Jack> uncached pages.

Sounds like we're in violent agreement! ;-)

	--david
