From: Andreas Schwab <schwab@suse.de>
Date: Tue, 27 Nov 2001 13:04:15 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.16)
Message-Id: <marc-linux-ia64-105590698805549@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> An updated ia64 patch for 2.4.16 is now available at
|> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:
|>=20
|>         linux-2.4.16-ia64-011126.diff*
|>=20
|> change log:
|>=20
|> 	- update for 2.4.15/2.4.16:
|> 		- add show_trace_task()
|> 		- lots of SGI SN updates (most in "sn" subdirectories)
|> 		- IA-32 brk() fix by Don Dugger
|> 	- drop some of the more cosmetic fixes (they will be in the 2.5 tree
|> 	  instead)
|> 	- fix EARLY_PRINTK (Tony Luck, I think)
|> 	- in iosapic.c, move RTE programming to a saner place (Alex Williamson)
|> 	- fix alignment of bootmap
|> 	- move machvec_init() a little earlier and call platform_cpu_init() at
|> 	  end of cpu_init() (Jack Steiner)
|> 	- swiotlb.c: support "page" member in scatterlist
|> 	- fix asm clobbers in spinlock.h
|> 	- add more ACPI tables to asm-ia64/acpi-ext.h
|>=20
|> This kernel has been tested with gcc-3.0 on Big Sur and HP Ski
|> simulator.  As usual, your mileage may vary.

You have renamed numnodes in mm/numa.c, but not in include/linux/mmzone.h,
and there are many occurences of "extern int num_compact_nodes" all over
the place.  I'm wondering why it was renamed in the first place.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

