From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Wed, 04 Aug 2004 16:30:35 +0000
Subject: RE: CONFIG_FORCE_MAX_ZONEORDER
Message-Id: <01EF044AAEE12F4BAAD955CB7506494301FB54AB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <012401c47a28$70fb62a0$39624c0f@asiapacific.cpqcorp.net>
In-Reply-To: <012401c47a28$70fb62a0$39624c0f@asiapacific.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Sourav Sen <> wrote on Wednesday, August 04, 2004 6:39 AM:

> Hi,
> 
> Is there a way of changing the value of MAX_ORDER
> using CONFIG_FORCE_MAX_ZOMEORDER? During 'make xconfig'
> I did not see a way. If I change it by hand in .config
> and then run make oldconfig, it gets changed back to
> the old value (= 18). The source version is 2.6.6
> 
> And, if it matters here -- I am on ia64.
> 
> Thanks
> Sourav
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64"
> in the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


arch/ia64/defconfig is the place where you want to make the change.
