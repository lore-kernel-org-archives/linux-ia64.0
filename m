From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 May 2003 00:48:09 +0000
Subject: [Linux-ia64] Re: 2.5.69 process.c: cpu_idle() cleanup
Message-Id: <marc-linux-ia64-105590723705745@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705738@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705738@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 12 May 2003 20:41:03 -0400, Jes Sorensen <jes@wildopensource.com> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
  David> Is this a real need or is this just something hypothetical?
  David> If the latter, I'd rather leave what's there now.

  Jes> The problem with the current code is that it doesn't work for
  Jes> generic kernels and for the SN2 we really like to have this
  Jes> feature in place.  The PROM allows you to go in and look at the
  Jes> led status even if the kernel has hung.

  Jes> The other reason was that I was trying to get rid of SN
  Jes> specific features from generic files and having a more generic
  Jes> API for this seemed useful to me.

  Jes> So to answer your question, yes I think there is a real use for
  Jes> this.

OK, I can probably live with that argument.  However, let's make it a
platform vector then (which I was opposed to back when) and make it a
single function (e.g., "mark_idle"), which takes an "idleness"
argument.

	--david

