From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Mon, 17 May 2004 07:35:02 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405170735.i4H7Z3Fv001532@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> There's been a lot of talk of what to do with hotplug CPUs as well.  No
> matter what, it's going to be really easy to notify whatever app you
> want with the hotplug scripts whenever a memory or CPU event happens. 
> Just place your app script in /etc/hotplug.d.

Just curious, but what's the underlying reason for providing CPU hotplug ?
If the background is taking a "bad" CPU offline, what kind of CPU failures
are expected to be covered ? 

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

