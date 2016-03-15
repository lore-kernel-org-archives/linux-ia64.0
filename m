From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Mar 2016 22:17:22 +0000
Subject: RE: [PATCH] ia64: define ioremap_uc()
Message-Id: <3908561D78D1C84285E8C5FCA982C28F3A00AEAE@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201603062005.lhOBibd1%fengguang.wu@intel.com>
	<1457382894-13553-1-git-send-email-mcgrof@kernel.org>
 <20160315151331.5359bfcece84a4889ecfd2d7@linux-foundation.org>
In-Reply-To: <20160315151331.5359bfcece84a4889ecfd2d7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "bp@suse.de" <bp@suse.de>

>> Note, this is actually needed since v4.3 to complete an allyesconfig
>> compile on ia64, there were others archs that needed this, and this
>> one just seems to have fallen through the cracks.
>
> So a cc:stable was needed.  I've added that to my copy of the patch. 
> Tony ack?

Acked-by: Tony Luck <tony.luck@intel.com>

