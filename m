From: Andreas Schwab <schwab@suse.de>
Date: Fri, 06 Apr 2001 14:41:23 +0000
Subject: Re: [Linux-ia64] New gnu-efi package and new boot loader available
Message-Id: <marc-linux-ia64-105590693005376@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005375@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005375@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Stephane Eranian <eranian@frankl.hpl.hp.com> writes:

|> Hi,
|>=20
|> I have uploaded to the HPLabs FTP site a new version of the gnu-efi=20
|> package.  It is available at:
|> =09
|> 	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-2.0.tar.gz

Here is a patch to make `elilo -C' working:

--- elilo/elilo.c
+++ elilo/elilo.c	2001/04/06 14:10:10
@@ -605,7 +605,7 @@
=20
 	argc =3D argify(info->LoadOptions,info->LoadOptionsSize, argv);=20
=20
-	while ((c=3DGetopt(argc, argv, W2U(L"Cadqht:i:vVf"))) !=3D -1 ) {
+	while ((c=3DGetopt(argc, argv, W2U(L"C:adqht:i:vVf"))) !=3D -1 ) {
 		switch(c) {
 			case 'a':
 				elilo_opt.always_alt=3D1;

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

