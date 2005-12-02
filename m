From: Andreas Schwab <schwab@suse.de>
Date: Fri, 02 Dec 2005 17:42:49 +0000
Subject: Reading /proc/stat is slooow
Message-Id: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

At some point after 2.6.13 reading /proc/stat has become too slow.  This
is most visible with xosview, which spends up to 80% in kernel space.  I
have attached a simple program that you can run with "strace -r" to see
that the second read of /proc/stat which eventually returns EOF takes too
much time.  If you remove the loop around read the same amount of time is
now spent in close.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

--=-=-=
Content-Disposition: attachment; filename=stat.c

#include <unistd.h>
#include <fcntl.h>

static char buf[8192];

int
main (int argc, char **argv)
{
  const char *file = argc > 1 ? argv[1] : "/proc/stat";
  while (1)
    {
      int fd = open (file, O_RDONLY);
      while (read (fd, buf, 8192) > 0);
      close (fd);
      usleep (300000);
    }
}

--=-=-=--
