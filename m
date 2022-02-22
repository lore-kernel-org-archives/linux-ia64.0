From: =?UTF-8?q?Ilpo=20J=C3=A4rvinen?= <ilpo.jarvinen@linux.intel.com>
Date: Tue, 22 Feb 2022 11:56:02 +0000
Subject: [PATCH 0/2] termbits.h cleanup
Message-Id: <20220222115604.7351-1-ilpo.jarvinen@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jirislaby@kernel.org>, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org

Two simple cleanup patches to termbits.h. I prefer these to go
in through tty-next as I've some other work based on them that
I'll submit later.

Ilpo J=C3=A4rvinen (2):
  ia64: termbits.h is identical to asm-generic one
  xtensa: termbits.h is identical to asm-generic one

 arch/ia64/include/uapi/asm/termbits.h   | 209 ----------------------
 arch/xtensa/include/uapi/asm/termbits.h | 221 ------------------------
 2 files changed, 430 deletions(-)
 delete mode 100644 arch/ia64/include/uapi/asm/termbits.h
 delete mode 100644 arch/xtensa/include/uapi/asm/termbits.h

--=20
2.30.2
