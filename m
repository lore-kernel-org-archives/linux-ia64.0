From: Andreas Schwab <schwab@suse.de>
Date: Mon, 31 Jul 2000 10:03:15 +0000
Subject: Re: [Linux-ia64] kernel update [relative to 2.4.0-test4]
Message-Id: <marc-linux-ia64-105590678205247@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205242@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205242@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is a small patch for arch/ia64/config.in: fs/nls/Config.in is already
sourced by fs/Config.in, no need to do it a second time.

--- arch/ia64/config.in	2000/07/31 10:00:23	1.1
+++ arch/ia64/config.in	2000/07/31 10:00:30
@@ -161,8 +161,6 @@
=20
 source fs/Config.in
=20
-source fs/nls/Config.in
-
 if [ "$CONFIG_VT" =3D "y" ]; then
   mainmenu_option next_comment
   comment 'Console drivers'

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg


