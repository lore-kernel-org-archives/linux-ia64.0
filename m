From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 19 Jan 2009 04:25:04 +0000
Subject: how to fix nand driver build breakage
Message-Id: <20090120132317.B0B3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <38D9F46DFF92C54980D2F2C1E8EE31301FC5E7FB@pdsmsx503.ccr.corp.intel.com>
In-Reply-To: <38D9F46DFF92C54980D2F2C1E8EE31301FC5E7FB@pdsmsx503.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gao, Yunpeng" <yunpeng.gao@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Hi all,
> 
> I have to use 64bit variable in my 2.6.27 kernel NAND driver as below:
> ---------------------------------------------------------------------------
> u64 NAND_capacity;
> unsigned int block_num, block_size;
> ...
> block_num = NAND_capacity / block_size;
> ---------------------------------------------------------------------------
> but it failed when compiling and reports 'undefined reference to `__udivdi3'.
> 
> Does any idea about this? I need to include some special head file or change something in Kconfig?
> 
> BTW, the environment is Fedora Core 9, gcc 4.3.0. 

Couldn't you use do_div()?



