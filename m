From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Sun, 25 Nov 2018 04:00:08 +0000
Subject: Re: [PATCH 8/8] socket: Add SO_TIMESTAMPING_NEW
Message-Id: <CAF=yD-Jz8c2EsoKxUDbf7dygWRW49kwteUsksq3eUV00Eg94-w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181124022035.17519-1-deepa.kernel@gmail.com> <20181124022035.17519-9-deepa.kernel@gmail.com>
In-Reply-To: <20181124022035.17519-9-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: David Miller <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, y2038 Mailman List <y2038@lists.linaro.org>, chris@zankel.net, fenghua.yu@intel.com, rth@twiddle.net, Thomas Gleixner <tglx@linutronix.de>, ubraun@linux.ibm.com, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-s390 <linux-s390@vger.kernel.org>, linux-xtensa@linux-xtensa.org, sparclinux@vger.kernel.org

On Sat, Nov 24, 2018 at 3:58 AM Deepa Dinamani <deepa.kernel@gmail.com> wrote:
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

>  /*
>   * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
>   * or sock_flag(sk, SOCK_RCVTSTAMPNS)
> @@ -739,8 +740,8 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>         struct sk_buff *skb)
>  {
>         int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP) || sock_flag(sk, SOCK_RCVTSTAMPNS);
> -       struct scm_timestamping tss;
> -       int empty = 1, false_tstamp = 0;
> +       struct scm_timestamping_internal tss;
> +       int empty = 1, false_tstamp = 0, new_tstamp = 0;
>         struct skb_shared_hwtstamps *shhwtstamps >                 skb_hwtstamps(skb);
>
> @@ -756,20 +757,23 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>
>         memset(&tss, 0, sizeof(tss));
>         if ((sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE) &&
> -           ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
> +           ktime_to_timespec64_cond(skb->tstamp, tss.ts + 0))
>                 empty = 0;
>         if (shhwtstamps &&
>             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
>             !skb_is_swtx_tstamp(skb, false_tstamp) &&
> -           ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
> +           ktime_to_timespec64_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
>                 empty = 0;
>                 if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_PKTINFO) &&
>                     !skb_is_err_queue(skb))
>                         put_ts_pktinfo(msg, skb);
>         }
>         if (!empty) {
> -               put_cmsg(msg, SOL_SOCKET,
> -                        SO_TIMESTAMPING_OLD, sizeof(tss), &tss);
> +               new_tstamp = sock_flag(sk, SOCK_TSTAMP_NEW);
> +               if (new_tstamp)

nit: no need for explicit variable

> +                       put_cmsg_scm_timestamping64(msg, &tss);
> +               else
> +                       put_cmsg_scm_timestamping(msg, &tss);
>
>                 if (skb_is_err_queue(skb) && skb->len &&
>                     SKB_EXT_ERR(skb)->opt_stats)
> --
> 2.17.1
>
