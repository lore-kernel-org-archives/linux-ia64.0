From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 07 Jun 2004 23:02:00 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16580.62440.981776.824795@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 7 Jun 2004 15:48:57 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  >>  Eh, you need to worry about races.  There can be a timer-tick
  >> while get_offset is running.

  Christoph> get_offset is invoked from gettimeofday with a
  Christoph> seqlock. In that case it would repeat its actions. I can
  Christoph> put an explicit seqlock into get_offset?

I guess I wasn't clear enough: if you update "last_nsec_offset" in
get_offset(), then you might have committed a "bad" value into a
global variable.  Bad.  The seq-lock won't help you there, because the
global variable alreayd has been polluted with a bad value.

	--david
