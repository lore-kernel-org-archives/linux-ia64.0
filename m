From: Andreas Schwab <schwab@suse.de>
Date: Fri, 16 Mar 2001 17:20:42 +0000
Subject: Re: [Linux-ia64] Possible bug in getname32
Message-Id: <marc-linux-ia64-105590693005286@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005284@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005284@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-9"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"David Engebretsen" <engebret@us.ibm.com> writes:

|> Although I do not work on linux-ia64, I believe we found a bug bringing =
up
|> PPC64 that also exists in the IA64 code that someone might want to look
|> into.
|>=20
|> In arch/ia64/ia32/sys_ia32.c, the function getname32 allocates storage v=
ia
|> __get_free_page and then returns it via putname (aka kmem_cache_free).
|> This mismatch of storage allocation schemes can cause all kinds of subtle
|> problems as we found in PPC64.
|>=20
|> Is this a legitimate bug, or are we missing something here?

Yes, I think that this is a bug.  Here is a patch:

--- sys_ia32.c	2001/03/16 17:08:13	1.1
+++ sys_ia32.c	2001/03/16 17:15:12
@@ -2762,11 +2762,12 @@
 do_getname32(const char *filename, char *page)
 {
 	int retval;
+	unsigned long len =3D PATH_MAX + 1;
=20
 	/* 32bit pointer will be always far below TASK_SIZE :)) */
-	retval =3D strncpy_from_user((char *)page, (char *)filename, PAGE_SIZE);
+	retval =3D strncpy_from_user((char *)page, (char *)filename, len);
 	if (retval > 0) {
-		if (retval < PAGE_SIZE)
+		if (retval < len)
 			return 0;
 		return -ENAMETOOLONG;
 	} else if (!retval)
@@ -2780,7 +2781,7 @@
 	char *tmp, *result;
=20
 	result =3D ERR_PTR(-ENOMEM);
-	tmp =3D (char *)__get_free_page(GFP_KERNEL);
+	tmp =3D __getname();
 	if (tmp)  {
 		int retval =3D do_getname32(filename, tmp);
=20

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

