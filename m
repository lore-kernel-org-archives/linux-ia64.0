From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 12 Dec 2018 15:25:04 +0000
Subject: Re: [PATCH v2 7/8] socket: Add SO_TIMESTAMPING_NEW
Message-Id: <CAF=yD-+mrKfq35g+EVkP-pNbBL=6BvYDdduks=yAxiADSRWvzg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181211202520.16799-1-deepa.kernel@gmail.com> <20181211202520.16799-8-deepa.kernel@gmail.com>
In-Reply-To: <20181211202520.16799-8-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: David Miller <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, y2038 Mailman List <y2038@lists.linaro.org>, Chris Zankel <chris@zankel.net>, fenghua.yu@intel.com, rth@twiddle.net, Thomas Gleixner <tglx@linutronix.de>, ubraun@linux.ibm.com, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-s390 <linux-s390@vger.kernel.org>, linux-xtensa@linux-xtensa.org, sparclinux@vger.kernel.org

On Tue, Dec 11, 2018 at 3:30 PM Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>
> Add SO_TIMESTAMPING_NEW variant of socket timestamp options.
> This is the y2038 safe versions of the SO_TIMESTAMPING_OLD
> for all architectures.
>
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: chris@zankel.net
> Cc: fenghua.yu@intel.com
> Cc: rth@twiddle.net
> Cc: tglx@linutronix.de
> Cc: ubraun@linux.ibm.com
> Cc: linux-alpha@vger.kernel.org
> Cc: linux-arch@vger.kernel.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-mips@linux-mips.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-xtensa@linux-xtensa.org
> Cc: sparclinux@vger.kernel.org
> ---
>  arch/alpha/include/uapi/asm/socket.h  |  5 +-
>  arch/mips/include/uapi/asm/socket.h   |  5 +-
>  arch/parisc/include/uapi/asm/socket.h |  5 +-
>  arch/sparc/include/uapi/asm/socket.h  |  8 +--
>  include/linux/socket.h                |  7 +++
>  include/uapi/asm-generic/socket.h     |  5 +-
>  include/uapi/linux/errqueue.h         |  4 ++
>  net/core/scm.c                        | 27 ++++++++++
>  net/core/sock.c                       | 73 +++++++++++++++------------
>  net/ipv4/tcp.c                        | 29 ++++++-----
>  net/smc/af_smc.c                      |  3 +-
>  net/socket.c                          | 15 ++++--
>  12 files changed, 122 insertions(+), 64 deletions(-)
>
> diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
> index 352e3dc0b3d9..8b9f6f7f8087 100644
> --- a/arch/alpha/include/uapi/asm/socket.h
> +++ b/arch/alpha/include/uapi/asm/socket.h
> @@ -116,19 +116,20 @@
>
>  #define SO_TIMESTAMP_NEW         62
>  #define SO_TIMESTAMPNS_NEW       63
> +#define SO_TIMESTAMPING_NEW      64
>
>  #if !defined(__KERNEL__)
>
>  #if __BITS_PER_LONG = 64
>  #define SO_TIMESTAMP           SO_TIMESTAMP_OLD
>  #define SO_TIMESTAMPNS         SO_TIMESTAMPNS_OLD
> +#define SO_TIMESTAMPING                SO_TIMESTAMPING_OLD
>  #else
>  #define SO_TIMESTAMP (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMP_OLD : SO_TIMESTAMP_NEW)
>  #define SO_TIMESTAMPNS (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPNS_OLD : SO_TIMESTAMPNS_NEW)
> +#define SO_TIMESTAMPING (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPING_OLD : SO_TIMESTAMPING_NEW)
>  #endif

If the previous patch moves this block to a platform-independent
header, that allows this patch to shrink considerably, too.

> +static int setsockopt_timestamping(struct sock *sk, int type, int val)
> +{
> +       if (type = SO_TIMESTAMPING_NEW)
> +               sock_set_flag(sk, SOCK_TSTAMP_NEW);
> +
> +       if (val & ~SOF_TIMESTAMPING_MASK)
> +               return -EINVAL;
> +
> +       if (val & SOF_TIMESTAMPING_OPT_ID &&
> +           !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
> +               if (sk->sk_protocol = IPPROTO_TCP &&
> +                   sk->sk_type = SOCK_STREAM) {
> +                       if ((1 << sk->sk_state) &
> +                           (TCPF_CLOSE | TCPF_LISTEN))
> +                               return -EINVAL;
> +                       sk->sk_tskey = tcp_sk(sk)->snd_una;
> +               } else {
> +                       sk->sk_tskey = 0;
> +               }
> +       }
> +
> +       if (val & SOF_TIMESTAMPING_OPT_STATS &&
> +           !(val & SOF_TIMESTAMPING_OPT_TSONLY))
> +               return -EINVAL;
> +
> +       sk->sk_tsflags = val;
> +       if (val & SOF_TIMESTAMPING_RX_SOFTWARE) {
> +               sock_enable_timestamp(sk,
> +                                     SOCK_TIMESTAMPING_RX_SOFTWARE);
> +       } else {
> +               if (type = SO_TIMESTAMPING_NEW)
> +                       sock_reset_flag(sk, SOCK_TSTAMP_NEW);
> +               sock_disable_timestamp(sk,
> +                                      (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE));
> +       }
> +
> +       return 0;
> +}
> +
>  /*
>   *     This is meant for all protocols to use and covers goings on
>   *     at the socket level. Everything here is generic.
> @@ -851,39 +890,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
>                 break;
>
>         case SO_TIMESTAMPING_OLD:
> -               if (val & ~SOF_TIMESTAMPING_MASK) {
> -                       ret = -EINVAL;
> -                       break;
> -               }
> -
> -               if (val & SOF_TIMESTAMPING_OPT_ID &&
> -                   !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
> -                       if (sk->sk_protocol = IPPROTO_TCP &&
> -                           sk->sk_type = SOCK_STREAM) {
> -                               if ((1 << sk->sk_state) &
> -                                   (TCPF_CLOSE | TCPF_LISTEN)) {
> -                                       ret = -EINVAL;
> -                                       break;
> -                               }
> -                               sk->sk_tskey = tcp_sk(sk)->snd_una;
> -                       } else {
> -                               sk->sk_tskey = 0;
> -                       }
> -               }
> -
> -               if (val & SOF_TIMESTAMPING_OPT_STATS &&
> -                   !(val & SOF_TIMESTAMPING_OPT_TSONLY)) {
> -                       ret = -EINVAL;
> -                       break;
> -               }
> -
> -               sk->sk_tsflags = val;
> -               if (val & SOF_TIMESTAMPING_RX_SOFTWARE)
> -                       sock_enable_timestamp(sk,
> -                                             SOCK_TIMESTAMPING_RX_SOFTWARE);
> -               else
> -                       sock_disable_timestamp(sk,
> -                                              (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE));
> +               ret = setsockopt_timestamping(sk, optname, val);

Once again a lot of needless code churn. The only functional change is adding

   +       if (type = SO_TIMESTAMPING_NEW)
   +               sock_set_flag(sk, SOCK_TSTAMP_NEW);


>  void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>         struct sk_buff *skb)
>  {
> +
>         int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
> -       struct scm_timestamping tss;
> +       struct scm_timestamping_internal tss;
> +

Unnecessary whitespace line

>         int empty = 1, false_tstamp = 0;
>         struct skb_shared_hwtstamps *shhwtstamps >                 skb_hwtstamps(skb);
> @@ -755,20 +758,22 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>
