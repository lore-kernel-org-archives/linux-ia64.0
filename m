From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 17:55:06 +0000
Subject: RE: [Linux-ia64] High fpu register corruption
Message-Id: <marc-linux-ia64-105590723705692@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 May 2003 10:14:20 -0700, "Mallick, Asit K" <asit.k.mallick@intel.com> said:

  Asit> David, The save part in the context switch also needs to be
  Asit> fixed and we will take a look at this.

Are you sure?  It looks fine to me.  What's the scenario you're
worried about?  Note that if an application clears psr.mfh it says: I
no longer care about the state, next time I touch it, give me whatever
contents you have (either all zeroes or an earlier snapshot of fph;
never the contents of fph from another thread, of course).

Note that the fph registers are all scratch registers.  Are you
worried about someone implementing a non-standard calling convention?
Even then I think an application that clears psr.mfh is saying that
the fph contents is no longer relevant, so I think we'd still be OK.

	--david

