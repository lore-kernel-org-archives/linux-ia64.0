From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 18 Sep 2001 19:33:12 +0000
Subject: Re: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805215@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 18 Sep 2001 19:50:52 +0200, Andreas Jaeger <aj@suse.de> said:

  >> It turns out that three of the four resulting possibilities make
  >> sense:
  >> 
  >> (1) ia64/ilp32 (2) ia64/lp64 (3) x86/ilp32

  Andreas> Then we should discuss where those will end.  For ia64, the
  Andreas> places are according to the proposal:

  Andreas> (1) not defined
  Andreas> (2) /lib and /usr/lib
  Andreas> (3) not defind - but not /lib

(2) is fine, but I think LSB should also (3)---at least for ia64.
It's important for distributors to agree on the local of (3).  The
current proposal is /emul/ia32-linux.

  >> Now, as far as /libXX is concerned: in my opinion, /lib should
  >> contain the "native" or "preferred" library format (primarily for
  >> source compatibility and user convenience reasons).  LSB is in
  >> denial if it claims /lib is used for 32-bit libraries only.  Both
  >> IA-64 and Alpha use it for 64-bit libraries and if, god forbid,
  >> someone ever added ILP32 support to IA-64 Linux, those libraries
  >> would certainly go into /lib32 or something of that sort.  LSB
  >> should consider and accommodate this case.

  Andreas> The proposal should just do this - and defines the
  Andreas> "preferred" library format.  For both ia64 and Alpha, it's
  Andreas> 64-bit but for PPC64, Sparc64 etc it's 32-bit.

If that's the idea, good.  From the description that you quoted, it
sounded like the "Alpha case" was there solely for historical
purposes, which would be misleading.  /lib should *always* contain the
"preferred" library format.

	--david

