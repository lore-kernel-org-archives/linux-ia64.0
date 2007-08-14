From: Bernhard Walle <bwalle@suse.de>
Date: Tue, 14 Aug 2007 21:36:28 +0000
Subject: Re: BINIT and physical address
Message-Id: <20070814213628.GA825@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <32209efe0708131042p68748b3el85d3ec4d76864244@mail.gmail.com>
In-Reply-To: <32209efe0708131042p68748b3el85d3ec4d76864244@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Luck, Tony <tony.luck@intel.com> [2007-08-14 23:10]:
> But there isn't a user-mode accessible way to convert them to
> physical addresses.

Well, there is a way (indirectly).

Because there's /dev/mem, any userspace program can expose the page tables of
the kernel.  If you have debugging information of the kernel available, you can
use the crash utility (http://people.redhat.com/~anderson/) which is normally
used to analyse dump files in the running system.

    $ crash -s
    crash> vtop 0xa00000020b520000
    VIRTUAL           PHYSICAL        
    a00000020b520000  a3078494000     

    PAGE DIRECTORY: a000000100708000
       PGD: a000000100708000 => 30030ac000
       PUD: e0000030030ac000 => 3006d54000
       PMD: e000003006d54828 => 63003f44000
       PTE: e000063003f46a40 => 100a3078494661
      PAGE: a3078494000

         PTE         PHYSICAL    FLAGS
    100a3078494661  a3078494000  (P|MA_WB|PL_0|AR_RWX|A|D|ED)

          PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
    a0007ffb2ffcc018 a3078494000      -------       -----   0 500000000000000

Of course it may be easier to use a simple kernel module. ;-)


Thanks,
   Bernhard
