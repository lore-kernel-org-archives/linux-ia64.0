From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Sat, 24 Jul 2004 07:05:10 +0000
Subject: Re: [PATCH] - Update function prototype for sn_io_addr
Message-Id: <16642.2598.302948.228394@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040723122907.GA7308@sgi.com>
In-Reply-To: <20040723122907.GA7308@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jack" = Jack Steiner <steiner@sgi.com> writes:

Jack> Add "const" to function prototype for sn_io_addr. Cuts boot time
Jack> on simulator in half.

Is this the SKI simulator?  I can't currently build Linux in
CONFIG_GENERIC mode to run on the simulator (you can't build the
bootloader, and if you work around that by compiling the bootloader
with CONFIG_HP_SIM the result hangs in very early boot).   And
sn_io_addr isn't included if you compile with CONFIG_HP_SIM.

So I'm interested to know what you're doing.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
