From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Sep 2005 12:45:00 +0000
Subject: Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050927124500.GA16050@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We could be more aggressive than other arches but still follow the cautious
> path.  I'm reluctant to suggest this but adding a couple of default 
> configuration files with SPARSEMEM might be useful.  Perhaps 
> sn2_defconfig_sparsemem and defconfig_sparsemem. 
> 

Although many developers at SGI use SN-specific configuration files,
customers run SuSE & RH and use kernels built with the GENERIC config 
since the kernel binary runs on all hardware vendors platforms.
It is important to make the default config file run efficiently
on all platforms.

I haven't looked in detail at SPARSEMEM recently - is one config
file for ALL hardware platforms easy to do without significantly 
compromising performance of any individual platform?


-- 
Jack


