From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 15 Nov 2004 19:13:00 +0000
Subject: RE: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <16792.65468.560191.832441@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 14 Nov 2004 12:07:10 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> This isn't for correctness, or even efficiency (since this is
  Tony> a very low frequency execution path).  It is just to make the
  Tony> code easier to read and maintain.

Ah, I see.  I guess that makes some sense.

	--david
