From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 Jan 2003 19:15:59 +0000
Subject: RE: [Linux-ia64] [Patch] trivial fix in linker script
Message-Id: <marc-linux-ia64-105590709805773@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 Jan 2003 10:30:52 -0800, "Siddha, Suresh B" <suresh.b.siddha@intel.com> said:

  Suresh> I am using GNU linker.

I see.

  Suresh> Inline with your observation, Intel compiler emits the type
  Suresh> of extern variables. And now based on the order in which
  Suresh> object files are linked, linker is failing in some cases.

  Suresh> If the object file with extern declaration comes after the
  Suresh> object file with correct declaration, linker is working
  Suresh> fine. But if the object file with extern declaration comes
  Suresh> first, then linker is reporting "type of symbol changed" in
  Suresh> the second object file with correct declaration.

Huh, and this is a fatal error, not a warning?

  Suresh> gcc doesn't fix the type for extern variables, leaves it to
  Suresh> the linker. So linking works irrespective of the order.

  Suresh> Is this a GNU linker issue?

Perhaps.  We might want to discuss it with Richard Henderson.
Currently the GNU linker is a bit overzealous in enforcing certain
restrictions anyhow, which make it a pain for the linux kernel (e.g.,
it doesn't allow the mixing of CONST_GP and non-CONST_GP files, even
if the non-CONST_GP files contain only data, etc.).  Perhaps it's just
time to clean up the toolchain in this regard.

Don't get me wrong: I can live with the linker script magic if the
toolchain folks argue that it is the proper way to handle this.  I
just want to avoid uglifying the kernel for no good reason.

	--david

