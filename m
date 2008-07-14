From: Christian Kandeler <christian.kandeler@hob.de>
Date: Mon, 14 Jul 2008 13:53:19 +0000
Subject: Initialization order problem
Message-Id: <200807141553.19341.christian.kandeler@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I've spotted the following problem: In function start_kernel() (file 
init/main.c), there are two calls to printk(), followed by 
setup_arch(). However, if the kernel is configured to use timing 
information on calls to printk(), then printk() will call 
cpu_clock(), which uses per-cpu data. For ia64, the physical address 
for the per-cpu data is kept in ar.k3, which is only initialized in 
cpu_init(), which is called by setup_arch(), i.e. AFTER the calls to 
printk(). 

Regards,
Christian Kandeler
