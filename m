From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Thu, 23 Aug 2001 15:29:48 +0000
Subject: [Linux-ia64] mca messages
Message-Id: <marc-linux-ia64-105590698805098@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Running 2.4.8+patch on a 4X Lion, I got a bunch of these:

    ia64_mca_cpe_int_handler : received interrupt. vector = 0x1e
    ia64_log_get : Failed to retrieve SAL error record type 3

The VGA went quite wacky on my as well: those two lines were
flickering on top of each other in the VTs.  If I <returned>
to scroll down, the lines at the bottom were normal, but the
lines above still had both lines flickering on top of each other.
When I changed VTs, the lines reappeared on the screen.

Anyone know what is up?

Kevin

