From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Nov 2003 21:24:33 +0000
Subject: RE: Problems using psr.dd
Message-Id: <marc-linux-ia64-106936365907105@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106879020623297@msgid-missing>
In-Reply-To: <marc-linux-ia64-106879020623297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Nov 2003 12:29:42 -0800, "Seth, Rohit" <rohit.seth@intel.com> said:

  Rohit> Erratum 11 applies to the cases where rfi is followed by RSE
  Rohit> generating instruction in static code stream (i.e. in the
  Rohit> source).

Ah, so Keith's interpretation was correct.

  Rohit> Have not looked at the Keith's changes but hopefully he has
  Rohit> not put any instruction like alloc after rfi in the source.

No, quite the opposite: he put NOPs around it.  So clearly this
remains an open issue.

	--david
