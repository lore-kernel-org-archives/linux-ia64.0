From: Keith Owens <kaos@sgi.com>
Date: Sat, 15 Dec 2001 02:03:53 +0000
Subject: [Linux-ia64] Re: fpswa patch(es)
Message-Id: <marc-linux-ia64-105590698805701@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, 14 Dec 2001 14:35:03 -0800,=20
David Mosberger <davidm@hpl.hp.com> wrote:
>We could include more info in /proc/cpuinfo.  E.g., we could include a
>count of the total number of fpswa and unaligned faults (on a per CPU
>basis).  (Alpha Linux does this, if you want to look for an example).
>If someone sent me a patch to do that, I'd be much more inclined to
>apply it.

FYI, SGI are looking at adding a generic framework for maintaining
per-cpu counters and providing low overhead access from user space to
that data.  We can already see performance problems with accessing
per-cpu counters via /proc, it does not scale.

http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=98578952028153&w=3D2


