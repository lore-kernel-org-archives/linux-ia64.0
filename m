From: Paul Mackerras <paulus@samba.org>
Date: Wed, 28 Jan 2004 04:44:39 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <16407.15927.632084.223700@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com>
	<Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Hironobu Ishii <ishii.hironobu@jp.fujitsu.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

Linus Torvalds writes:

> Does anybody see any downsides to something like this?

Looks OK to me.

On pSeries (ppc64) machines, we don't get an asynchronous machine
check, but instead the read will return all 1s, and the system will
isolate the slot and arrange that all further reads return all 1s.
If you get all 1s back on a read, you are supposed to do a firmware
call to find out if there was actually an error.

With your design, I would make readX_check set a bit somewhere
(associated with the dev argument) if it saw all 1s, and then make
read_pcix_errors do the firmware call if the bit is set.

The only thing to be careful of is that drivers cope correctly with an
all-1s value returned.  E.g. they shouldn't do:

	while (readb_check(dev, offset) & BUSY)
		udelay(1);

But of course they shouldn't do that anyway. :)

Paul.
