From: Xishi Qiu <qiuxishi@huawei.com>
Date: Mon, 25 Mar 2013 10:20:02 +0000
Subject: report: IA64 boot failed when set "mem=xxG" in sparse memory
Message-Id: <515024D2.6000008@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On IA64 platform, I change the config, set "Memory model (sparse Memory)",
do not set "Sparse Memory virtual memmap", others is based on SLES11's
default config(/boot/config-2.6.32.12-0.7-default).

After finish making a new kernel(v3.8), I add "mem=xxG" to the command line,
then reboot the system.

Boot failed and there is no print on the screen!

If both set "Memory model (sparse Memory)" and "Sparse Memory virtual memmap",
then add "mem=xxG" to the command line, reboot is OK.

I don't know whether it is a problem only in my system.

Thanks,
Xishi Qiu

