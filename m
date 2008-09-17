From: shaohua.li@intel.com
Date: Wed, 17 Sep 2008 08:13:20 +0000
Subject: [patch 0/4] IA64 utrace support
Message-Id: <20080917081320.626729280@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch set adds the utrace support for IA64. IA64 already had regset
support, so most hard part are done. This patches add other required changes
for utrace. Roland has a howto for arch porting, please see below link.

http://sourceware.org/systemtap/wiki/utrace/arch/HowTo

Thanks,
Shaohua
-- 
