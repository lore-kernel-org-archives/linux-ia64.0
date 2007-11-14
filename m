From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 14 Nov 2007 23:49:33 +0000
Subject: Re: [patch 1/1] ia64: increase .data.patch offset
Message-Id: <87mytgpeuq.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
In-Reply-To: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

>> What I'll do today, is try a number of different compiler version
>> (it's realtively easy for me to do this), and email tomorrow which
>> ones compile a generic kernel, and if I have time, which ones boot.

Tony> Are some versions of the compiler actually broken (and
Tony> generating spurious stuff so overflowing this section) ... or
Tony> are we just skating close to the edge so that minor differences
Tony> in generated code push us over the limit.

Some compilers are broken.  I think 3.5.4 is OK, except it's
generating some spurious stuff.

Tony> If the only reason to reject a compiler version can be fixed by
Tony> Andrew's patch to change the 0x500 to 0x600 in gate.lds.S, then
Tony> that seems a reasonable thing to do.

I agree.
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
