From: Andreas Schwab <schwab@suse.de>
Date: Mon, 14 Aug 2000 11:35:41 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test6)
Message-Id: <marc-linux-ia64-105590678205324@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|>  - Stephane's fixes for initrd.  The current version tolerates older
|>    version of eli, but if you're seeing a warning message of the form:
|>=20
|> 	Warning: boot loader passed virtual address for initrd
|>=20
|>    you should consider updating your bootloader.

This patch is needed to make it actually compile.

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

