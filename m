From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Mar 2016 22:15:58 +0000
Subject: RE: [PATCH] ia64: define ioremap_uc()
Message-Id: <3908561D78D1C84285E8C5FCA982C28F3A00AE6D@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201603062005.lhOBibd1%fengguang.wu@intel.com>
 <1457382894-13553-1-git-send-email-mcgrof@kernel.org>
 <20160315220706.GD1990@wotan.suse.de>
In-Reply-To: <20160315220706.GD1990@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "bp@suse.de" <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>

>> All architectures now need ioremap_uc(), ia64 seems defines
>> this already through its ioremap_nocache() and it already
>> ensures it *only* uses UC.
>> 
>> Reported-by: 0 day bot
>> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
>
> *Poke*

Luis,

Thanks for the reminder.  Applied.

-Tony
