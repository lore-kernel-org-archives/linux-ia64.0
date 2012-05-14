From: Tony Luck <tony.luck@gmail.com>
Date: Mon, 14 May 2012 21:26:48 +0000
Subject: Re: loading linux-3.3 with ski sim crashes
Message-Id: <CA+8MBbK6f+pEg=d5GEEsFRLOBgpbw+RhBsQbtKP+ZVFdCGekPA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201205110646.29925.vapier@gentoo.org>
In-Reply-To: <201205110646.29925.vapier@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, May 11, 2012 at 3:46 AM, Mike Frysinger <vapier@gentoo.org> wrote:
> i'm using gcc-4.5.3, binutils-2.22, and linux-3.3. =A0i did `make sim_def=
config`,
> then `make`, then `make boot`.

Al Viro got SKI to boot just over a week ago. The only problem that he
reported was this one:

http://www.spinics.net/lists/linux-scsi/msg59106.html

Your stack trace doesn't look all that likely to match this (no scsi anythi=
ng
in your trace) ... but worth trying either Al's patch or jejb's proposed be=
tter
patch.

-Tony
