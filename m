From: "Smith, Phil" <APhil.Smith@compaq.com>
Date: Wed, 13 Mar 2002 02:00:55 +0000
Subject: RE: [Linux-ia64] Linux-IA64 execution of ILP32 binaries
Message-Id: <marc-linux-ia64-105590701905248@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905245@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905245@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

My primary question wasn't as much about supporting ILP32 development
under Linux-IA64, but just executing binaries created under such an
environment. The biggest question should surround the VM address space,
which could be a subset of the Linux-IA64 map. If pointers are
sign-extended, a single region in a 61-bit address area can accommodate
the 32-bit range for x86. Obviously, things like big files could not be
accessed without special APIs for the 32-bit developers.
Commercial UNIX vendors (i.e., HP and Sun) have taken great pains to
provide a migration path. It seems that not accommodating this creates
GREATER market fragmentation, especially with more commercial products
being available on Linux. It seems ironic that 16-bit DOS, Windows and
32-bit Windows will still run under Wine or Win64, but 32-bit Linux
software on the market today won't run on Linux-IA64...

Perhaps it's a topic for another list, but does anyone know how the
Linux Standard Base will handle this ?

Phil Smith

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Tuesday, March 12, 2002 2:35 PM
To: Smith, Phil
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Linux-IA64 execution of ILP32 binaries


>>>>> On Tue, 12 Mar 2002 12:39:55 -0800, "Smith, Phil"
<APhil.Smith@compaq.com> said:

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

