From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 07 Jun 2004 18:14:00 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16580.45160.472402.207890@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 7 Jun 2004 10:46:41 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> Would it be possible to avoid any changes to arch
  Christoph> independent code by changing get_offset fir the ITC clock
  Christoph> to never return an earlier offset in the same tick?

I didn't think so.  The problem is that for ITC-interpolation, we
basically need a two-phase protocol: get an offset and if everything
is consistent, commit to the new offset.  You're welcome to try,
though.

	--david
