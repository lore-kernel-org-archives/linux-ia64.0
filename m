From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 27 Sep 2000 17:04:15 +0000
Subject: re: [Linux-ia64] setjmp/longjmp : flushing register stack
Message-Id: <marc-linux-ia64-105590678205519@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205495@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205495@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Sep 2000 12:07:24 -0400 (EDT), Steve Tynor <tynor@atlanta.twr.com> said:

  Steve> I've tried adding an inline asm("flushrs") before the setjmp,

Like I said before: the flushrs won't help at all.  The real issue is
preserving ar.rnat (which is probably a problem you have not run into
yet).

  Steve> but the local frame pointer (which seems to vary from
  Steve> function to function (gcc seems to use one of the general
  Steve> registers in the r33...r38 range -- and setjmp does not
  Steve> preserve those) is still not preserved after the longjmp (and
  Steve> local variables accessed in the new context are accessed off
  Steve> the old context's value of the frame register.).

This doesn't sound right.  The local registers of the function calling
setjmp/longjmp are preserved (not the output registers though, of
course).  Can you investigate?

	--david

