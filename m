From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Thu, 20 Mar 2003 20:07:32 +0000
Subject: RE: [Linux-ia64] [patch] logical CPU numbering
Message-Id: <marc-linux-ia64-105590723705279@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705277@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705277@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> If a CPU fails to start during smp_boot_cpus(), then the logical CPU
> numbering gets will have a "hole".  Using the number of booted CPU's
> instead of the loop index will correct this.

Just curious, does having a hole cause a problem?
It might well; I don't know.

I consider some future scenario where if cpu X
didn't come up, it can be hot-replaced, at which
point one might actually want to have that "slot"
reserved for it. 

