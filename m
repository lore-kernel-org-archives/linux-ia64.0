From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Tue, 07 Dec 2004 15:54:30 +0000
Subject: Re: CPU hot-remove - Handoff Processor to SAL
Message-Id: <200412071554.iB7FsVKv002274@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041206220159.A7973@unix-os.sc.intel.com>
In-Reply-To: <20041206220159.A7973@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Is this just a debugging printk?  I wouldn't be too happy if a customer
> > sees the message "Now cpu 3 is dead" in their logs.  I can almost hear
> > the terrified support call now ...
> 
> Very funny!! 
> 
> I will change it, if there are any updates in the next round.

I would make it a systune, so all startrek fans would get
"He's dead Jim" :-))

> > "I asked the machine to take the CPU offline and now it's dead!  My boss
> > is going to kill me!"

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

