From: Luming Yu <luming.yu@gmail.com>
Date: Thu, 14 Jan 2010 05:15:42 +0000
Subject: Re: lockdep support caused an MCA
Message-Id: <3877989d1001132115n596441b1j600143f36d335f1d@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100111195825.GE10162@ldl.fc.hp.com>
In-Reply-To: <20100111195825.GE10162@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
> How many cells was your system? Mine was 2 cells (for a total of
> 16 CPUs). I just mention this because booting on a 1 cell config
> is quite different from a multi-cell config.

Looks like mine is a 2 cells system too, judging by the 16 CPUS brought
up from another part of boot log, which  comes from same boot as my
previous mail in this thread.

...
Brought up 16 CPUs
Total of 16 processors activated (50987.00 BogoMIPS).
...

Thanks,
Luming
