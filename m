From: "Sourav Sen" <souravs@india.hp.com>
Date: Wed, 04 Aug 2004 13:51:17 +0000
Subject: CONFIG_FORCE_MAX_ZONEORDER
Message-Id: <012401c47a28$70fb62a0$39624c0f@asiapacific.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi,

Is there a way of changing the value of MAX_ORDER
using CONFIG_FORCE_MAX_ZOMEORDER? During 'make xconfig'
I did not see a way. If I change it by hand in .config
and then run make oldconfig, it gets changed back to
the old value (= 18). The source version is 2.6.6

And, if it matters here -- I am on ia64. 

Thanks
Sourav
