From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 12 Mar 2002 22:35:15 +0000
Subject: Re: [Linux-ia64] Linux-IA64 execution of ILP32 binaries
Message-Id: <marc-linux-ia64-105590701905247@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905245@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905245@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 12 Mar 2002 12:39:55 -0800, "Smith, Phil" <APhil.Smith@compaq.com> said:

  Phil> Has co-existance / running of 32-bit (ILP32) Linux executables
  Phil> been addressed such that they could run under the LP64 data
  Phil> model of Linux-IA64 ? If not, shouldn't the IA-64 section of
  Phil> the Linux Standard Base address this ? I've only seen
  Phil> references to the Intel ABI documents, which I don't believe
  Phil> cover some of the (considerable)interoperability issues that
  Phil> would be involved...

This comes up periodically and the answer remains the same: IA-64
Linux is LP64 _only_ and there is no effort to add ILP32 support.  A
primary reason for this is to avoid market fragmentation, though there
are other reasons as well (see mailing list archive for earlier
discussions).

Of course, if you just want to run an old binary, you can get ILP32 in
the form of an x86 binary, but that won't perform at native speeds.

	--david

