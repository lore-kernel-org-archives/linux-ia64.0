From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 14 Mar 2005 04:16:46 +0000
Subject: Context switch time regression...
Message-Id: <16949.4142.908795.242198@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



According to LMbench2 on a 2-way 900MHz Itanium 2:

Context switching 0K - times in microseconds - smaller is better
----------------------------------------------------------------
OS                               2p/0k      4p/0k      8p/0k
                               ctx swtch  ctx swtch  ctx swtch 
-----------------------------  ---------  ---------  ---------
Linux 2.5.72                   1.5700000  1.6200000  1.7700000
Linux 2.6.0                      15.0600  8.6900000  8.8600000
Linux 2.6.11                     17.1900    17.2100    10.5400

I have to go now, but I'll try to track this down tomorrow.


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
