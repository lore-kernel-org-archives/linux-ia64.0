From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 13 Nov 2004 07:05:34 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <16789.45630.286536.174428@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Nov 2004 17:27:27 -0600 (CST), Russ Anderson <rja@sgi.com> said:

  Russ> Tony and all, This is a smaller version of the per cpu
  Russ> MCA/INIT save area patch.  The main point is to get in the
  Russ> infrastructure for the per cpu MCA/INIT save areas.  It
  Russ> allocates a per cpu MCA/INIT save area and used ar.k3 to hold
  Russ> a pointer to the area.

Can you remind me why k3?  Are you worried about the TR mapping the
per-CPU region getting corrupted?

	--david
