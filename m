From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Mar 2006 23:22:36 +0000
Subject: RE: Fw: [Bugme-new] [Bug 6307] New: Bug hwclock in kernel 2.6.16
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061AAD86@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060330112531.1959b11e.akpm@osdl.org>
In-Reply-To: <20060330112531.1959b11e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Subject: [Bugme-new] [Bug 6307] New: Bug hwclock in kernel 2.6.16
>...
>> Most recent kernel where this bug did not occur: Kernel 2.6.8-2-itanium-smp 
>> (Defauld in Debian 3.1)
>
>I can't reproduce this with kernel.org 2.6.15 on an HP rx2600.

My HP rx2620, HP zx2000 and Intel Tiger are all running 2.6.16-gitlatest and
none of them hang on hwclock or ntpdate either.

The config file listed in the bugzilla has a zillion differences from
arch/ia64/defconfig ... and chance of trying with a kernel based on
this config?

-Tony
