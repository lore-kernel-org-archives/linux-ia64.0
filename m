From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 23 Jul 2007 21:17:00 +0000
Subject: Re: Linus' tree broken?
Message-Id: <87tzrustv7.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Doug" = Doug Chapman <doug.chapman@hp.com> writes:

Doug> On Mon, 2007-07-23 at 15:41 +0200, Jes Sorensen wrote:
>> Hi,
>> 
>> Have anyone else had seen issues with the Linus git tree failing to
>> boot? I'm trying a pull as of this morning and it seems to hang
>> when it's brining up the ethernet devices.

Bringing up on Ski I see, `Out of interrupt vectors' --- see
http://www.gelato.unsw.edu.au/kerncomp/results//2007-07-23-17-00/sim_defconfig-boot.html


