From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 21 Jun 2006 03:17:07 +0000
Subject: [RFC 0/3] Page table shuffling
Message-Id: <20060621031707.22750.57782.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Prompted by kexec [1], I decided to revive a simplified version of
this patch.  This should make no functional changes, but should make
it slightly easier for fresh eyes to navigate the IA64 VM layer.

Against 2.6.17 and tested on the simulator (with a slight fix [2]) and
ZX1.

Thanks,

-i

[1] http://www.gelato.unsw.edu.au/archives/linux-ia64/0606/18542.html
[2] http://www.gelato.unsw.edu.au/archives/linux-ia64/0606/18550.html
