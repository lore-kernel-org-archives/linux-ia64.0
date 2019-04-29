From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 29 Apr 2019 11:34:07 +0000
Subject: Re: [PATCH] ia64: fix ptrace(PTRACE_GETREGS) (unbreaks strace, gdb)
Message-Id: <906b63c0-9032-995b-f1a4-4eb384e26314@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <def7f1cf-96b1-b0a9-88b8-3d24eb3b6075@physik.fu-berlin.de>
In-Reply-To: <def7f1cf-96b1-b0a9-88b8-3d24eb3b6075@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>
Cc: Sergei Trofimovich <slyfox@gentoo.org>, Frank Scheiner <frank.scheiner@web.de>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi!

On 4/29/19 12:38 PM, John Paul Adrian Glaubitz wrote:
> Is there a chance that Sergey's patch from [1] could get applied upstream?

Apparently it's sufficient to rebuild the kernel with a gcc which has
this [1] fix applied. Will give this a try and report back.

Adrian

> [1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=86984

--=20
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
