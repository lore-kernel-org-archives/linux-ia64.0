From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jun 2004 05:50:15 +0000
Subject: Re: Why large stack frame for PAL call
Message-Id: <16609.791.65478.362755@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
In-Reply-To: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 27 Jun 2004 10:42:14 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> Does anyone know why we need such large stack frame for PAL
  Ken> static call?  PAL isn't even suppose to touch any stack
  Ken> register for static calling convention.  Is it for legacy
  Ken> reason or something?

Good question.  I was able to track the source down to a patch that
was sent to me by Walt Drummond on Aug 11, 1999.  The authors listed
in the relevant file (it was called palcall.S back then) were Don
Dugger and Walt Drummond (in this order), so my guess is the code was
originally written by Don.  At that time, the primary target for Don
would have been SoftSDV.  Perhaps it was to work around a bug in
SoftSDV, though I suspect it's just as likely that the code came about
by a misunderstood/misdocumented PAL-requirement.

Perhaps Don or Asit remember how this came about?

I also cannot find a requirement that would demand allocating 96
stacked registers before making a PAL call and I'd be in favor of
cleaning that up.

	--david
