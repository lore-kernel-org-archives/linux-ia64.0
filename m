From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 04 Aug 2004 16:26:28 +0000
Subject: Re: CONFIG_FORCE_MAX_ZONEORDER
Message-Id: <200408040926.28467.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <012401c47a28$70fb62a0$39624c0f@asiapacific.cpqcorp.net>
In-Reply-To: <012401c47a28$70fb62a0$39624c0f@asiapacific.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wednesday, August 4, 2004 6:39 am, Sourav Sen wrote:
> Hi,
>
> Is there a way of changing the value of MAX_ORDER
> using CONFIG_FORCE_MAX_ZOMEORDER? During 'make xconfig'
> I did not see a way. If I change it by hand in .config
> and then run make oldconfig, it gets changed back to
> the old value (= 18). The source version is 2.6.6
>
> And, if it matters here -- I am on ia64.

If you really want to change it, you'll have to edit arch/ia64/Kconfig and 
change FORCE_MAX_ZONEORDER.

Jesse
