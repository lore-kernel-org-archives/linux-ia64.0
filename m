From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 09 Apr 2002 01:46:18 +0000
Subject: [Linux-ia64] My HP simulator config patch...
Message-Id: <marc-linux-ia64-105590701905420@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	Now I've had a chance to play with some real hardware,  I
realise my patch to move the selection of CONFIG_BLK_DEV_RAM etc into
arch/ia64/config.in breaks `make xconfig'.

One cannot select the ramdisc on any platform other than HPSIM with my
patch applied. 

It looks as if xconfig can't cope with the same symbol appearing in
more than one place.

I'm not sure whether this is worth fixing in the config.in files, as
make config, make menuconfig and make oldconfig all work right.

Peter C

