From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sun, 11 May 2003 18:10:12 +0000
Subject: Re: [Linux-ia64] as & .restore sp directive
Message-Id: <marc-linux-ia64-105590723705725@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705723@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705723@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 11 May 2003 19:50:17 +0200, Ronald Veldema <veldema@cs.fau.de> said:

  Ronald> Hi all, my java compiler now compiles quite a bit of java.*
  Ronald> and so Am looking at the unwind info that I need to emit.  I
  Ronald> now have a problem with the .restore directive.  It looks
  Ronald> like I can only emit it once or as dies.

  Ronald> Given:

  Ronald> if (condition) { ...; return; } else { ...; return; }

  Ronald> I emit two function trailers (restoring b0, resetting sp,
  Ronald> etc.)  and in doing so I also emit two ".restore sp"
  Ronald> directives and as dies with:

  Ronald> out.s: Assembler messages: out.s:79: Error: Epilogue count
  Ronald> of 4294967296 exceeds number of nested prologues (0)

  Ronald> Adding two .prologue statements or two ".restore sp, 1"
  Ronald> won't work. Any ideas ?

Looks like you need to upgrade the assembler.  This is a known bug in
earlier versions (sorry, I don't recall when exactly this was fixed).

	--david

