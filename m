From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 22 Feb 2003 02:30:32 +0000
Subject: Re: [Linux-ia64] strange performance behaviour with floats
Message-Id: <marc-linux-ia64-105590709805905@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Feb 2003 20:59:47 +0100, Volker Birk <vb@ebios.de> said:

  Volker> On Thu, Feb 20, 2003 at 09:52:43AM -0800, David Mosberger
  Volker> wrote:

  >> Hmmh, that's really strange.  I assume you realize that your
  >> test-program doesn't really do what the source code suggests (the
  >> loop-body gets optimized away), but regardless the high variation
  >> you're seeing seems wrong.

  Volker> I think, optimazation does not matter on that point.

I looked into this a bit more.  Your test program is basically a
1-cycle loop:

4000000000000770:       0a 00 00 00 01 00       [MMI]       nop.m 0x0
4000000000000776:       00 00 00 02 00 00                   nop.m 0x0
400000000000077c:       00 00 04 00                         nop.i 0x0
4000000000000780:       1c 00 00 00 01 00       [MFB]       nop.m 0x0
4000000000000786:       00 00 00 02 00 a0                   nop.f 0x0
400000000000078c:       f0 ff ff 48                         br.cloop.sptk.few 40
This is because gcc optimizes away to loop-body.  If you change the loop
to:

        for (i=0;i<1000000000;i++) {
		asm volatile ("nop 0;;");
        }

you'll get a 2-cycle loop which will execute consistently in 2 seconds
(on a 1GHz McKinley), which is what you'd expect.  1-cycle loops are
never optimal on McKinley (that's why the Linux bogomips comes out at
1438 instead of 2000, for example), though I don't know the exact
micro-architectural details that cause this.

	--david

