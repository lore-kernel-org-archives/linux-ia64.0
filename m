From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jun 2004 21:43:15 +0000
Subject: RE: Why large stack frame for PAL call
Message-Id: <16609.57971.744388.366433@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
In-Reply-To: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jun 2004 09:20:49 -0700, "Mallick, Asit K" <asit.k.mallick@intel.com> said:

  Asit> I rechecked some of my old documents and found that there was
  Asit> version of the SDM that stated that the caller should ensure
  Asit> that all 96 stacked registers are available before calling PAL
  Asit> procedure.

Ah, that sounds vaguely familiar.

  Asit> However, this restriction was removed in subsequent documents
  Asit> and is no longer needed.  The code did not get updated. So,
  Asit> Ken's patch should be fine.

I guess we should try it on a Merced box, just to be reasonably sure.
I'll do that.

I guess this points out a weakness in the "checkstack" script: it
ought to add the space allocated by the "alloc" instructions as well.
Since the script is written in the wrong language (OK, at least the
language-name starts with "p", I'll give them credit for that ;-), I
won't try to fix this.  Perhaps someone else wants to bite?

	--david
