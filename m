From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 18 Sep 2001 20:53:44 +0000
Subject: Re: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805220@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 18 Sep 2001 22:07:53 +0200, Andreas Jaeger <aj@suse.de> said:

  Andreas> But there are the following questions which I hope to get
  Andreas> solved:
  Andreas> - what's the preferred format on a platform?
  Andreas> - where will the other formats live?
  Andreas> - where should
  Andreas> emulations live?

Yes, these need to be answered, though it shouldn't be hard.  For
ia64, I think the answers would be:

	preferred format: lp64
	other formats:	  undefined (may want to mention that ia64 UNIX ABI
			  specifies /lib32 for ilp32; there are no plans to
			  support this under Linux)
	emulations:	  /emul/[<arch>-]<opsys> in general,
			  /emul/ia32-linux for the specific case of Linux/i386

Thanks,

	--david

