From: syzbot <syzbot+61acc40a49a3e46e25ea@syzkaller.appspotmail.com>
Date: Thu, 13 Aug 2020 03:57:04 +0000
Subject: Re: INFO: task hung in pipe_release (2)
Message-Id: <0000000000001d3cbb05acba4cc2@google.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <00000000000084b59f05abe928ee@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: James.Bottomley@HansenPartnership.com, amanieu@gmail.com, arnd@arndb.de, benh@kernel.crashing.org, bfields@fieldses.org, borntraeger@de.ibm.com, bp@alien8.de, catalin.marinas@arm.com, chris@zankel.net, christian@brauner.io, corbet@lwn.net, cyphar@cyphar.com, dalias@libc.org, davem@davemloft.net, deller@gmx.de, dvyukov@google.com, fenghua.yu@intel.com, geert@linux-m68k.org, gor@linux.ibm.com, heiko.carstens@de.ibm.com, hpa@zytor.com, ink@jurassic.park.msu.ru, jcmvbkbc@gmail.com, jhogan@kernel.org, jlayton@kernel.org, kvalo@codeaurora.org, linux-alpha@vger.kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux@armlinux.org.uk, linux@dominikbrodowski.net, linuxppc-dev@lists.ozlabs.org, luis.f.correia@gmail.com, luto@kernel.org, martink@posteo.de, mattst88@gmail.com, ming.lei@canonical.com, ming.lei@redhat.com, mingo@redhat.com, monstr@monstr.eu

syzbot has bisected this issue to:

commit fddb5d430ad9fa91b49b1d34d0202ffe2fa0e179
Author: Aleksa Sarai <cyphar@cyphar.com>
Date:   Sat Jan 18 12:07:59 2020 +0000

    open: introduce openat2(2) syscall

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=164e716a900000
start commit:   6ba1b005 Merge tag 'asm-generic-fixes-5.8' of git://git.ke..
git tree:       upstream
final oops:     https://syzkaller.appspot.com/x/report.txt?x=154e716a900000
console output: https://syzkaller.appspot.com/x/log.txt?x=114e716a900000
kernel config:  https://syzkaller.appspot.com/x/.config?x=84f076779e989e69
dashboard link: https://syzkaller.appspot.com/bug?extidaacc40a49a3e46e25ea
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=142ae224900000

Reported-by: syzbot+61acc40a49a3e46e25ea@syzkaller.appspotmail.com
Fixes: fddb5d430ad9 ("open: introduce openat2(2) syscall")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection
