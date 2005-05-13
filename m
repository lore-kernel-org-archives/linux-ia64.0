From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 May 2005 21:05:56 +0000
Subject: Re: heads up: apparent GAS bug in current (CVS) binutils
Message-Id: <17029.5812.552722.635968@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
In-Reply-To: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 13 May 2005 14:01:11 -0700, "H. J. Lu" <hjl@lucon.org> said:

  >> However, there still seems to be a binutils issues here: if this
  >> is something binutils cannot properly support, it should issue an
  >> error, not silently generate wrong code, no?

  HJ> I will see what I can do.

BTW: Thanks for tracking this down!  I had no idea this weird
"overloading" was going on.

	--david
