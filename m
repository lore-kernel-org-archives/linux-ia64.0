From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Tue, 24 Feb 2004 00:22:37 +0000
Subject: [BUG] 2.6.3 Slab corruption: errors are triggered when memory exceeds 2GB
Message-Id: <20040224002237.GE8906@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Ia64 Linux <linux-ia64@vger.kernel.org>


On Ia64 Itanium 1 machines with more than 2.5GB of RAM the follwing error is triggered.
 
slab error in check_poison_obj(): cache `size-16384': object was modified after freeing

The machine that triggered the error above is an

i2000 HP workstation
4gb RAM
1gb SWAP

An identical machine with 2.5GB ram produces:

slab error in check_poison_obj(): cache `size-2048': object was modified after freeing

if the amount of RAM is reduced to 2GB or less then the errors do not appear.

Kernel logs and configs can be found at:
http://quasar.cse.unsw.edu.au/~dsw/public-files/lemon-debug/


--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
