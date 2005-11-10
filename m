From: Andreas Schwab <schwab@suse.de>
Date: Thu, 10 Nov 2005 14:09:55 +0000
Subject: __put_user_size generates invalid asm
Message-Id: <je64r0iogc.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The macro __put_user_size in <asm/uaccess.h> can generate invalid
assembler code.  The problem is that the %P1 operand can expand to a
register, but the stX insn does not allow a register as increment.  This
happens for example when compiling the rme96xx module with gcc 4.1.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
