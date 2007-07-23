From: Jes Sorensen <jes@sgi.com>
Date: Mon, 23 Jul 2007 13:41:58 +0000
Subject: Linus' tree broken?
Message-Id: <46A4B026.9030307@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Have anyone else had seen issues with the Linus git tree failing to
boot? I'm trying a pull as of this morning and it seems to hang when
it's brining up the ethernet devices.

It's not locking up, just the boot scripts never continues - happens
both on SLES10 and FC7 roots :(

Just wanted to check before spending real time on it.

Cheers,
Jes
