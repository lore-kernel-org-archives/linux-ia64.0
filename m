From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 14 Aug 2000 17:00:05 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test6)
Message-Id: <marc-linux-ia64-105590678205325@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Yes, I goofed when merging in Stephane's changes (and Stephane told me
just about 10 minutes after I mailed out the patch).  It obviously
compiles fine if you don't turn on INITRD support, which is why I
didn't notice.

	--david

Andreas> David Mosberger <davidm@hpl.hp.com> writes:
Andreas> |>  - Stephane's fixes for initrd.  The current version tolerates =
older
Andreas> |>    version of eli, but if you're seeing a warning message of th=
e form:
Andreas> |>=20
Andreas> |> 	Warning: boot loader passed virtual address for initrd
Andreas> |>=20
Andreas> |>    you should consider updating your bootloader.

Andreas> This patch is needed to make it actually compile.

--- arch/ia64/kernel/setup.c	2000/08/14 09:17:15	1.1
+++ arch/ia64/kernel/setup.c	2000/08/14 11:30:51
@@ -157,7 +157,7 @@
 		if (initrd_start >=3D PAGE_OFFSET)
 			printk("Warning: boot loader passed virtual address "
 			       "for initrd, please upgrade the loader\n");
-		} else
+		else
 #endif
 			/*=20
 			 * The loader ONLY passes physical addresses

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg

