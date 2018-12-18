From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Dec 2018 16:16:20 +0000
Subject: Re: [PATCH v2 7/8] socket: Add SO_TIMESTAMPING_NEW
Message-Id: <CAK8P3a1xeZsrOv4+xhL5dbi02zfQcPEJvWDzmUNkFKmQubMkSA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181211202520.16799-1-deepa.kernel@gmail.com>
 <20181211202520.16799-8-deepa.kernel@gmail.com> <CAF=yD-+mrKfq35g+EVkP-pNbBL=6BvYDdduks=yAxiADSRWvzg@mail.gmail.com>
In-Reply-To: <CAF=yD-+mrKfq35g+EVkP-pNbBL=6BvYDdduks=yAxiADSRWvzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Cc: Deepa Dinamani <deepa.kernel@gmail.com>, David Miller <davem@davemloft.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Networking <netdev@vger.kernel.org>, y2038 Mailman List <y2038@lists.linaro.org>, Chris Zankel <chris@zankel.net>, Fenghua Yu <fenghua.yu@intel.com>, Richard Henderson <rth@twiddle.net>, Thomas Gleixner <tglx@linutronix.de>, ubraun@linux.ibm.com, linux-alpha@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-ia64@vger.kernel.org, "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-xtensa@linux-xtensa.org, sparclinux <sparclinux@vger.kernel.org>

On Wed, Dec 12, 2018 at 4:25 PM Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Tue, Dec 11, 2018 at 3:30 PM Deepa Dinamani <deepa.kernel@gmail.com> wrote:

> > @@ -851,39 +890,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
> >                 break;
> >
> >         case SO_TIMESTAMPING_OLD:
> > -               if (val & ~SOF_TIMESTAMPING_MASK) {
> > -                       ret = -EINVAL;
> > -                       break;
> > -               }
> > -
> > -               if (val & SOF_TIMESTAMPING_OPT_ID &&
> > -                   !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
> > -                       if (sk->sk_protocol = IPPROTO_TCP &&
> > -                           sk->sk_type = SOCK_STREAM) {
> > -                               if ((1 << sk->sk_state) &
> > -                                   (TCPF_CLOSE | TCPF_LISTEN)) {
> > -                                       ret = -EINVAL;
> > -                                       break;
> > -                               }
> > -                               sk->sk_tskey = tcp_sk(sk)->snd_una;
> > -                       } else {
> > -                               sk->sk_tskey = 0;
> > -                       }
> > -               }
> > -
> > -               if (val & SOF_TIMESTAMPING_OPT_STATS &&
> > -                   !(val & SOF_TIMESTAMPING_OPT_TSONLY)) {
> > -                       ret = -EINVAL;
> > -                       break;
> > -               }
> > -
> > -               sk->sk_tsflags = val;
> > -               if (val & SOF_TIMESTAMPING_RX_SOFTWARE)
> > -                       sock_enable_timestamp(sk,
> > -                                             SOCK_TIMESTAMPING_RX_SOFTWARE);
> > -               else
> > -                       sock_disable_timestamp(sk,
> > -                                              (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE));
> > +               ret = setsockopt_timestamping(sk, optname, val);
>
> Once again a lot of needless code churn. The only functional change is adding

I think moving the code out into a separate function is a useful cleanup,
but if we want to do that, it may be better done in another patch, to
make it easier to review.

       Arnd
