From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 06 Nov 2001 23:49:17 +0000
Subject: RE: [Linux-ia64] cpuinfo family changed in 2.4.7
Message-Id: <marc-linux-ia64-105590698805453@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805447@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805447@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 6 Nov 2001 23:03:06 +0100 (MET), Dan Pop <Dan.Pop@cern.ch> said:

  Dan> On Tue, 6 Nov 2001, David Mosberger wrote:

  >> >>>>> On Tue, 6 Nov 2001 14:42:35 -0600, "Donny Cooper"
  >> <dcooper@atcc.necsys.com> said:
  >> 
  Donny> David, What about the recently added "arch" field for 2.4.7,
  Donny> will it stay consistent in the kernel throughout each chip
  Donny> generation for Intel 64-bit.
  >>
  Donny> Currently --> arch : IA-64
  >>  Yup, it's hardcoded and I am not planing on changing it.

  Dan> Hasn't Intel officially renamed it IPF?

The official line from HP is that the architecture has been renamed to
"Itanium Processor Family" or "IPF" in short (I believe that's also
Intel's line, but I won't pretend to speak for Intel).

I'm not planning on changing from IA-64 to IPF for a very pragmatic
reason: there is just too much software out there that is testing for
ia64 already (if we changed the "arch" field, we presumably would have
to change the output of "uname -m" and so on...).

I also agree with Jim's sentiment that we need to emphasize that Linux
(and everything that goes on top of it) is designed for the
*architecture* not for a particular CPU model.  The terms "IA-64" and
"Itanium" make this distinction clear.  In contrast, "IPF" and
"Itanium" muddle the two.

	--david

PS: I do have to admit though that if I ever have to give a talk on
    IA-64 in German, I'll certainly be using IPF instead.  No interest
    in sounding like a donkey! ;-)

