From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Feb 2003 02:16:57 +0000
Subject: [Linux-ia64] Re: strange performance behaviour with floats
Message-Id: <marc-linux-ia64-105590709805913@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805910@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805910@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Feb 2003 13:01:10 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Which loop needs unrolling?  __delay generates

  Keith> 2d0:       11 00 00 00 01 00       [MIB]       nop.m 0x0
  Keith> 2d6:       00 70 04 55 00 00                   mov.i ar.lc=r14
  Keith> 2dc:       00 00 00 20                         nop.b 0x0;;
  Keith> 2e0:       11 00 00 00 01 00       [MIB]       nop.m 0x0
  Keith> 2e6:       00 00 00 02 00 a0                   nop.i 0x0
  Keith> 2ec:       00 00 00 40                         br.cloop.sptk.few 2e0 <calibrate_delay+0x100>;;

  Keith> br.cloop is already a single bundle loop.

You're toying with me, right? ;-)

Let me say this again: you _don't_ want a single-cycle loop.  You want
a 2-cycle loop that gets twice the work done as a 1-cycle loop.  That
is, you'd want to decrement the loop counter by 2, compare it against
zero, and branch if it's not zero yet, all the while making sure you
get a 2-cycle loop.

	--david

