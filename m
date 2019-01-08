From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 08 Jan 2019 13:37:07 +0000
Subject: Re: [PATCH v3 0/8] net: y2038-safe socket timestamps
Message-Id: <CAF=yD-JuXHnp-5TvPSq87PDvHD1hkrUEWHQ9Uxwhbsd08vszHw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190108032657.8331-1-deepa.kernel@gmail.com>
In-Reply-To: <20190108032657.8331-1-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: David Miller <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, y2038 Mailman List <y2038@lists.linaro.org>, Chris Zankel <chris@zankel.net>, Helge Deller <deller@gmx.de>, David Howells <dhowells@redhat.com>, fenghua.yu@intel.com, isdn@linux-pingi.de, "James E.J. Bottomley" <jejb@parisc-linux.org>, linux-afs@lists.infradead.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-rdma@vger.kernel.org, linux-s390 <linux-s390@vger.kernel.org>, linux-xtensa@linux-xtensa.org, Ralf Baechle <ralf@linux-mips.org>, rth@twiddle.net, sch

On Mon, Jan 7, 2019 at 10:29 PM Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>
> The series introduces new socket timestamps that are
> y2038 safe.
>
> The time data types used for the existing socket timestamp
> options: SO_TIMESTAMP, SO_TIMESTAMPNS and SO_TIMESTAMPING
> are not y2038 safe. The series introduces SO_TIMESTAMP_NEW,
> SO_TIMESTAMPNS_NEW and SO_TIMESTAMPING_NEW to replace these.
> These new timestamps can be used on all architectures.
>
> The alternative considered was to extend the sys_setsockopt()
> by using the flags. We did not receive any strong opinions about
> either of the approaches. Hence, this was chosen, as glibc folks
> preferred this.
>
> The series does not deal with updating the internal kernel socket
> calls like rxrpc to make them y2038 safe. This will be dealt
> with separately.
>
> Note that the timestamps behavior already does not match the
> man page specific behavior:
> SIOCGSTAMP
>     This ioctl should only be used if the socket option SO_TIMESTAMP
>         is not set on the socket. Otherwise, it returns the timestamp of
>         the last packet that was received while SO_TIMESTAMP was not set,
>         or it fails if no such packet has been received,
>         (i.e., ioctl(2) returns -1 with errno set to ENOENT).
>
> The recommendation is to update the man page to remove the above statement.
>
> The overview of the series is as below:
> 1. Delete asm specific socket.h when possible.
> 2. Support SO/SCM_TIMESTAMP* options only in userspace.
> 3. Rename current SO/SCM_TIMESTAMP* to SO/SCM_TIMESTAMP*_OLD.
> 3. Alter socket options so that SOCK_RCVTSTAMPNS does
>    not rely on SOCK_RCVTSTAMP.
> 4. Introduce y2038 safe types for socket timestamp.
> 5. Introduce new y2038 safe socket options SO/SCM_TIMESTAMP*_NEW.
>
> Changes since v2:
> * Removed extra functions to reduce diff churn as per code review

Thanks, Deepa. This set looks great to me.

One issue, it does not apply cleanly to current davem-net-next/master
for me. A conflict on patch 7. It does apply cleanly on davem-net
master. Please rebase and also send with [PATCH net-next].

Perhaps also run the selftests in
tools/testing/selftests/networking/timestamping/txtimestamp.sh, just
to be sure.

Since you have a to resend anyway, a few minor nits inline, as well.
