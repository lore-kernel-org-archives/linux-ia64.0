From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 22 Sep 2004 23:05:27 +0000
Subject: Re: rename generic_defconfig to defconfig?
Message-Id: <16722.1335.721880.301379@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409221713.12673.jbarnes@engr.sgi.com>
In-Reply-To: <200409221713.12673.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jesse" = Jesse Barnes <jbarnes@engr.sgi.com> writes:

Jesse> On Wednesday, September 22, 2004 5:25 pm, Luck, Tony wrote:
>> >Just thought I'd float the idea of making the ia64 defconfig >into
>> a generic ia64 kernel config.  It's probably easiest just >to
>> rename generic_defconfig to defconfig since that already >works
>> everywhere (well, except for akpm's box apparently).  >That would
>> make it extra easy to build a working kernel for >the various ia64
>> boxes out there...

Generic_defconfig still doesn't work on the simulator, yet.  So we at
least need that config hanging around too.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
