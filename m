From: "Yu, Luming" <luming.yu@intel.com>
Date: Tue, 12 Jan 2010 01:51:16 +0000
Subject: RE: lockdep support caused an MCA
Message-Id: <1EC975D79B8B1F4BBDC50EA54418A0040C635FE1B1@shzsmsx501.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100111195825.GE10162@ldl.fc.hp.com>
In-Reply-To: <20100111195825.GE10162@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Let me check if I can get access to an HP rx8640 to re-spin the patch.


-----Original Message-----
From: Alex Chiang [mailto:achiang@hp.com] 
Sent: Tuesday, January 12, 2010 3:58 AM
To: Yu, Luming; Luck, Tony
Cc: linux-ia64@vger.kernel.org
Subject: lockdep support caused an MCA

This patch 2f02b4a12b24c9f077c6d739ac23c9b90840ccca:

Author: Luming Yu <luming.yu@intel.com>  2009-12-04 09:14:30

    [IA64] lockdep support
    
    Basic functionality for lockdep on ia64.
    
    Known issues:
    0. dynamic allocate per CPU area in lockdep.
    1. lock held in leave kernel.
    2. enabling CONFIG_DEBUG_LOCKDEP triggers the lockdep warning.
    3. Need to implement save_stack functions
    4. Replace some cpp macros with inline functions
    5. Add nmi_enter/nmi_exit
    
    Signed-off-by: Bob Picco <bob.picco@hp.com>
    Signed-off-by: Yu Luming <luming.yu@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

causes a very early MCA on an HP rx8640.

Unfortunately, even with early_printk turned on, the machine
encounters the MCA and reboots before any output occurs, so I
don't have any further information.

I haven't done any other triage on this as the patch has already
been dropped from Tony's tree, but I'd be happy to test the next
go-around.

Thanks,
/ac

