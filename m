From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Apr 2003 23:37:01 +0000
Subject: Re: [Linux-ia64] ia32 subsystem in 2.5.67
Message-Id: <marc-linux-ia64-105590723705524@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705513@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705513@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 16 Apr 2003 14:09:38 -0700, Arun Sharma <arun.sharma@intel.com> said:

  Arun> David Mosberger <davidm@napali.hpl.hp.com> writes:
  Arun> Hi David,

  >> It looks like dynamic x86 binaries have a problem once again (or
  >> still).  If I try to run any shared x86 binaries, I get:
  >> 
  >> $ ls.x86
  >> ls.x86: error while loading shared libraries: librt.so.1: cannot map zero-fill pages: Error 14
  >> 
  >> Would someone take a look?

  Arun> We saw this behavior with 2.5.59 also. The attached work around should
  Arun> take care of the problem temporarily. Last time this happened, IA-32
  Arun> programs were doing mmaps, whose size was one page bigger than the
  Arun> size of the underlying file (even after rounding up the file size).

  Arun> I never got a chance to figure out why glibc was doing mmaps with the
  Arun> "wrong" size. Also, I failed to reproduce the problem with a more
  Arun> recent (RH 8.0) glibc.

Oops, looks like I may have dropped that patch by accident?  I'm
sorry, if so.

  Arun> Which version of IA-32 glibc were you using ?

Huh, good question.  It looks like it's glibc v2.2.5.

	--david

