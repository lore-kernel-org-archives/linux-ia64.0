From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Mon, 12 Nov 2001 16:08:18 +0000
Subject: [Linux-ia64] PTHREAD_PROCESS_SHARED not supported
Message-Id: <marc-linux-ia64-105590698805471@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Current version of libpthread (libpthread-0.9.so based on glibc-2.2.3)=20
provided with RH 7.1 distribution do not support PTHREAD_PROCESS_SHARED fla=
g;
  pthread_mutexattr_setpshared(&mutatr, PTHREAD_PROCESS_SHARED) returns ENO=
SYS.

Does a patch exist that implements it or are they plans to do that ?

Thanks in advance.

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

