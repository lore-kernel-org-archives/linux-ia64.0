From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 21 Sep 2004 05:10:42 +0000
Subject: Re: RFC - freeing up ar.k5
Message-Id: <200409210510.i8L5Agi19760@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's the results from lmbench ... 10 iterations without my patch, and
then 10 iterations with it.  I'm not sure that I can see which is better.
Even at the 2p/0K end the run-to-run variance is high enough (12.3 to 12.9)
that any differences introduced by my change are hidden in the noise.

Access time for the ar.k registers runs to several cycles ... so a cache
hit on a percpu variable replacement would beat the register by a small
amount, a cache miss would lose out.

Context switching - times in microseconds - smaller is better
-------------------------------------------------------------------------
Host                 OS  2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                         ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
--------- ------------- ------ ------ ------ ------ ------ ------- -------
linux-t03 Linux 2.6.9-r   12.8   13.1   12.7 5.7800 9.9000 4.81000 9.50000
linux-t03 Linux 2.6.9-r   12.6   13.6   12.4 8.3900 9.0900 5.50000 9.03000
linux-t03 Linux 2.6.9-r   12.6   13.2   12.7 5.8300 7.6900 5.20000    10.1
linux-t03 Linux 2.6.9-r   12.3   13.5   12.5 8.5700   12.1 6.77000 9.56000
linux-t03 Linux 2.6.9-r   12.7   13.6   12.7 8.4100 8.2400 5.50000 8.21000
linux-t03 Linux 2.6.9-r   12.7   13.7   12.0 5.9700 8.8700 5.79000 8.47000
linux-t03 Linux 2.6.9-r   12.6   13.1   12.5 5.8300   12.7 6.13000 8.20000
linux-t03 Linux 2.6.9-r   12.7   13.5   12.6 8.2900   10.3 7.36000 9.60000
linux-t03 Linux 2.6.9-r   12.8   13.2   12.2   10.8 9.7100 6.02000 8.28000
linux-t03 Linux 2.6.9-r   12.7   13.6   12.4 8.5300 8.2200 5.68000 8.16000

linux-t03 Linux no ar.k5  12.7   13.2   12.5   11.0   10.5 5.37000 8.26000
linux-t03 Linux no ar.k5  12.5   13.6   12.4 8.5000   10.2 6.17000 9.91000
linux-t03 Linux no ar.k5  12.6   13.2   12.5 5.6400 7.6800 6.21000 9.47000
linux-t03 Linux no ar.k5  12.6   13.3   12.4 5.7700 7.5600 8.10000 8.60000
linux-t03 Linux no ar.k5  12.6   13.6   12.7 8.4500 8.0800 6.14000 8.12000
linux-t03 Linux no ar.k5  12.6   13.4 2.4400 5.7800 7.6600 5.72000 8.61000
linux-t03 Linux no ar.k5  12.8   13.4   12.5 8.4100 8.1600 4.77000 8.04000
linux-t03 Linux no ar.k5  12.6   13.4   12.7 8.2400 7.8700 5.34000 8.21000
linux-t03 Linux no ar.k5  12.9   13.4   12.5 5.7600 8.1100 6.75000 8.22000
linux-t03 Linux no ar.k5  12.8   13.6   12.5 5.7800 7.3600 5.32000 9.66000

Still not sure where to take this.  One suggestion I did get was to use
this as a proof of concept that ar.k5 could be freed up if some super
wonderful application for a ar.k register comes along, so it's ok to use
our last completely free register (ar.k3) for the INIT/MCA code.

-Tony
