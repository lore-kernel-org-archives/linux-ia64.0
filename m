From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 16:58:07 +0000
Subject: RE: [Linux-ia64] High fpu register corruption
Message-Id: <marc-linux-ia64-105590723705685@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 May 2003 09:33:55 -0700, "Mallick, Asit K" <asit.k.mallick@intel.com> said:

  Asit> Andreas, The high FP save and restore in the context switch
  Asit> makes the assumption that user will not be modifying the
  Asit> psr.mfh and it will be only updated by the hardware.

Not a chance.  We can't rely on the application doing the Right Thing.
In fact, having an application clear psr.mfh makes tons of sense,
when it knows it's done using mfh.

  Asit> Without this assumption we can not optimize the FP
  Asit> save/restore for SMP systems (this patch will not cover all
  Asit> cases). If application wants the current high fpu state to be
  Asit> preserved then it should will not be able to modify the
  Asit> psr.mfh.

  Asit> What kind of applications are trying to modify the mfh?

OpenSSL does (really: some underlying crypto code).

I think you're misunderstanding the problem though: the problem is
that application A clears psr.mfh and application B gets its fph state
corrupted.

So, really, this is just a bug that needs fixing.  It won't affect the
rest of the lazy fph save/restore logic.

	--david

