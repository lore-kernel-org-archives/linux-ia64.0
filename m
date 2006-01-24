From: Grant Grundler <iod00d@hp.com>
Date: Tue, 24 Jan 2006 18:42:46 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124184246.GG1528@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 24, 2006 at 08:40:55AM -0800, Grant Grundler wrote:
> > Brent, if you find a way to prevent this out-of-order write, please
> > remind me to include it in the mspec driver.
> 
> RDMA support will need something more general.
> (I'm asuming mspec is sn2 specific.)

nevermind...I think just made the same mistake as Brent.
RDMA userspace is talking to host memory, not MMIO.

grant
