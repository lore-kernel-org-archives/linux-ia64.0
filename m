From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Sep 2004 07:56:15 +0000
Subject: Re: INIT dumps broken?
Message-Id: <16711.62879.740326.646780@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 Sep 2004 17:16:47 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> The use of 0xa.. for cpu 0 is causing an MCA when cpu 0
  Keith> receives INIT.

The MINSTATE_PHYS-version of MINSTATE_GET_CURRENT() looks broken to
me.  Perhaps changing "dep reg=0,reg,61,3" to a "tpa" is all that's
needed there.  Can someone check this out?  I probably won't get to it
today and will be on vacation starting tomorrow.

	--david

