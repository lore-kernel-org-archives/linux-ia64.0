From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 18 May 2001 18:51:20 +0000
Subject: Re: [Linux-ia64] make cross-gcc error use GNUPro ToolKit
Message-Id: <marc-linux-ia64-105590693005623@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005611@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005611@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Copy /usr/include and /usr/lib from a ia64-linux system onto the ia32-linux
system, and then use the --with-headers=3DFOO --with-libs=BAR configure opt=
ions,
where FOO is the full pathname to the local copy of the IA-64 /usr/include =
and
BAR is the full pathname to the local copy of the IA-64 /usr/lib.

Building a complete working cross compiler is quite a bit of work.  It might
be easier to use one that someone else has built.  For instance, the one
available from HP that Stephane mentioned.

Jim

