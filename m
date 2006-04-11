From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 11 Apr 2006 01:39:24 +0000
Subject: booting with `mem=' on an Altix (or other NUMA machine)
Message-Id: <17467.2252.70039.423224@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Looks like booting with mem=xxx doesn't work very well on a NUMA
machine ... one sees, `ernel panic - not syncing: pernode space for
node 1 could not be allocated!'

It is intended that the mem= command line work?  It would have to be
quite a bit more complex if so, to spread the memory across online nodes.
-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
