From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Sun, 25 Nov 2018 05:07:35 +0000
Subject: Re: [PATCH 8/8] socket: Add SO_TIMESTAMPING_NEW
Message-Id: <CABeXuvoRPAFa5v86pp+WmBkjzbHZSJqjzibL1+Zx8Uas6bvohg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181124022035.17519-1-deepa.kernel@gmail.com>
 <20181124022035.17519-9-deepa.kernel@gmail.com> <CAF=yD-Jz8c2EsoKxUDbf7dygWRW49kwteUsksq3eUV00Eg94-w@mail.gmail.com>
In-Reply-To: <CAF=yD-Jz8c2EsoKxUDbf7dygWRW49kwteUsksq3eUV00Eg94-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: willemdebruijn.kernel@gmail.com
Cc: "David S. Miller" <davem@davemloft.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Network Devel Mailing List <netdev@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, y2038 Mailman List <y2038@lists.linaro.org>, Chris Zankel <chris@zankel.net>, fenghua.yu@intel.com, rth@twiddle.net, Thomas Gleixner <tglx@linutronix.de>, ubraun@linux.ibm.com, linux-alpha@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-ia64@vger.kernel.org, "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-xtensa@linux-xtensa.org, sparclinux <sparclinux@vger.kernel.org>

> > +               new_tstamp = sock_flag(sk, SOCK_TSTAMP_NEW);
> > +               if (new_tstamp)
>
> nit: no need for explicit variable

Sure, will drop it.

-Deepa
