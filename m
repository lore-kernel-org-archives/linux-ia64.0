From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 16 Mar 2004 07:34:43 +0000
Subject: Re: [patch] 2.6.4 remove intermittent warnings from spinlock code
Message-Id: <16470.44563.416335.867593@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2465.1079310276@kao2.melbourne.sgi.com>
In-Reply-To: <2465.1079310276@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 15 Mar 2004 11:24:36 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> The spinlock code writes to p14.  If gcc reuses p14 in the
  Keith> bundles immediately after the spinlock then we get warning
  Keith> messages.  Append a stop bit to the spinlock code to remove
  Keith> the warnings.  gcc 3.2.3, binutils 2.14.90.0.4.

  Keith> {standard input}: Assembler messages: {standard input}:2217:
  Keith> Warning: Use of 'tbit.z' violates WAW dependency 'PR%, % in 1
  Keith> - 15' (impliedf), specific resource number is 14 {standard
  Keith> input}:2217: Warning: Only the first path encountering the
  Keith> conflict is reported {standard input}:2211: Warning: This is
  Keith> the location of the conflicting usage

Hmmh, in my opinion GCC should put a stop-bit when using a register
after an "asm" that marks that register as "clobbered".  For now, I
put an explicit stop-bit after the McKinley spinlock versions (the
Merced ones should be OK because they already have a stop-bit after
writing p14).  We should still sort out why GCC doesn't get this
right.

	--david
