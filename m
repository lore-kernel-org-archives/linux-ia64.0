From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jun 2004 20:34:57 +0000
Subject: Re: PATCH: Don't use -mtune=merced for gcc 3.4
Message-Id: <16609.53873.239754.272457@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040628184040.GA13181@lucon.org>
In-Reply-To: <20040628184040.GA13181@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 28 Jun 2004 11:40:40 -0700, "H. J. Lu" <hjl@lucon.org> said:

  HJ> If people want to optimize kernel for Itanium 1, they can stick
  HJ> with the older gccs.  Or they should upgrade their machines. I
  HJ> think the gcc developer's time should be better spent on
  HJ> somewhere else.

I agree, but I do worry a bit whether this isn't an indication of a
deeper problem.  Let's hope not.  (I did apply the patch, thanks.)

	--david
