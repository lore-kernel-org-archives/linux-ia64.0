From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Apr 2003 22:02:40 +0000
Subject: RE: [Linux-ia64] ias and stack unwind
Message-Id: <marc-linux-ia64-105590723705481@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705471@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705471@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 11 Apr 2003 14:55:15 -0700, "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com> said:

  Jay> I don't think that explains it in my case.  I'm using ecc version 7.1.

Ugh, not good.

  Jay> Did you have to use any special options?

Nope, nothing special at all.  Please keep me posted on this.  I very
much want libunwind to work with all compilers.  I was happy to see
that ecc 7.0 puts out SCRA-compliant unwind info.  Let's hope it stays
so.

	--david

