From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 30 Jul 2001 22:36:32 +0000
Subject: Re: [Linux-ia64] gcc 3.0 question: ILP32 mode ?
Message-Id: <marc-linux-ia64-105590693005959@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 31 Jul 2001 00:06:48 +0200, Jes Sorensen <jes@sunsite.dk> said:

  Jose> Some code is just not worth cleaning up because it is too big,
  Jose> and will never require 64 bit addressing, but still useful to
  Jose> have in native mode, mostly because of the performance gap
  Jose> between ia32 and ILP32 which will moreover widen with the
  Jose> McKinley chip. Look at netscape, it has never been cleaned up,
  Jose> it was ported on linux alpha using the DEC/Compaq/(Intel now?)
  Jose> compiler in taso mode (32 bit pointers).

  Jes> Linux/Alpha's glibc doesn't support 32 bit pointers afaik.

Note that netscape doesn't/didn't get cleaned up for 64 bits because
Mozilla already *is* 64-bit clean.

I have yet to see a program that is worth running in natively yet not
worth cleaning up for 64 bits.

	--david

