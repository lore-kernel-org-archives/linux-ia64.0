From: Christian Hildner <christian.hildner@hob.de>
Date: Thu, 16 Sep 2004 12:39:01 +0000
Subject: Data translation registers/kernel stack
Message-Id: <41498965.3050003@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

reading translation registers from /proc/pal/cpu0/tr_info gives a page 
size for the kernel stack (dtr 2) of  8k (2.4.25 kernel). Wondering and 
looking through the whole linux kernel results in two things: First it 
seems that PAL reports wrong page sizes since dtr 0 reports a 16k page 
what is definitely wrong and second the kernel never ever inserts a 8k 
page for the kernel stack instead uses the configurable granule size. My 
machine is a ZX6000 900 MHZ Itanium2. May anybody having the same 
machine and maybe a newer one (1.3 GHz, ...) confirm that bug? Is there 
an update for PAL code?
My PAL version is
PAL_vendor : 0xff (min=0xff)
PAL_A      : 6.6.23 (min=6.6.23)
PAL_B      : 8.8.30 (min=7.6.0)

Christian

