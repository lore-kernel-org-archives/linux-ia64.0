From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 May 2004 21:35:03 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16546.39047.87546.787693@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 May 2004 14:24:42 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  >> This all just seems incredibly fragile to me.

  Jesse> I think it's useful for at least a subset of the I/O MCAs
  Jesse> that people see, and with the addition of the read_check
  Jesse> stuff, may be more generally useful.  Obviously though, this
  Jesse> doesn't recover from 100% of I/O errors, something that's
  Jesse> probably not practical anyway...

It definitely falls in the experimental category.  That isn't bad but
I don't think it's mainline material.  Certainly not for 2.6.

	--david
