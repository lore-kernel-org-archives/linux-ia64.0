From: Andreas Schwab <schwab@suse.de>
Date: Wed, 08 May 2002 21:49:10 +0000
Subject: Circular dependency between asm/system.h and asm/processor.h (Was:
Message-Id: <marc-linux-ia64-105590701905558@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

|> The latest ia64 patch relative to 2.4.18 is now available
|> at ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/
|> in file:
|>=20
|> 	linux-2.4.18-ia64-020410.diff.gz

local_irq_restore in asm/system.h needs IA64_PSR_I which is only defined
in asm/processor.h.  linux/tqueue.h defines the inline function queue_task
that uses spin_unlock_irqrestore, which is defined in terms of
local_irq_restore, so it does not compile because IA64_PSR_I is undefined.
But asm/processor.h already depends on asm/system.h, so we cannot just
include it there.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

