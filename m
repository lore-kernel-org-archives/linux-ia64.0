From: Andreas Schwab <schwab@suse.de>
Date: Fri, 20 Jun 2003 11:38:05 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105610921423687@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

|> A patch to make 2.5.72 work on ia64 is now available in the usual
|> place:
|>=20
|>   ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/
|> 	linux-2.5.72-ia64-030619.diff.bz2

A generic kernel does not compile.  Any idea how to fix?

  CC      arch/ia64/sn/io/sgi_io_sim.o
In file included from include/asm/nodedata.h:17,
                 from include/asm/sn/sn_cpuid.h:20,
                 from include/asm/sn/sn_sal.h:17,
                 from arch/ia64/sn/io/sgi_io_sim.c:13:
include/asm/mmzone.h:51:1: warning: "kern_addr_valid" redefined
In file included from include/asm/uaccess.h:36,
                 from include/asm/sn/sgi.h:17,
                 from arch/ia64/sn/io/sgi_io_sim.c:12:
include/asm/pgtable.h:191:1: warning: this is the location of the previous =
definition
In file included from include/asm/sn/sn_cpuid.h:20,
                 from include/asm/sn/sn_sal.h:17,
                 from arch/ia64/sn/io/sgi_io_sim.c:13:
include/asm/nodedata.h:27: error: `NR_NODES' undeclared here (not in a func=
tion)
include/asm/nodedata.h:28: error: `NR_BANKS' undeclared here (not in a func=
tion)
include/asm/nodedata.h:29: error: `NR_NODES' undeclared here (not in a func=
tion)
include/asm/nodedata.h:30: error: `NR_BANKS' undeclared here (not in a func=
tion)
In file included from include/asm/sn/sn_cpuid.h:21,
                 from include/asm/sn/sn_sal.h:17,
                 from arch/ia64/sn/io/sgi_io_sim.c:13:
include/asm/sn/pda.h:59: error: `NR_NODES' undeclared here (not in a functi=
on)
include/asm/sn/pda.h:63: confused by earlier errors, bailing out
make[2]: *** [arch/ia64/sn/io/sgi_io_sim.o] Error 1
make[1]: *** [arch/ia64/sn/io] Error 2
make: *** [arch/ia64/sn] Error 2

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
