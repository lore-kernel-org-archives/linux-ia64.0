From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Mon, 31 Mar 2008 10:51:54 +0000
Subject: Re: [17/17][PATCH] kvm/ia64: How to boot up guests on kvm/ia64 -V8
Message-Id: <A0C8931D3BDA53takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEF@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, Xiantao

>+3. Get Guest Firmware named as Flash.fd, and put it under right place:
>+	(1) If you have the guest firmware (binary)released by Intel
>Corp for Xen, you can use it directly.
>+	(2) If you want to build a guest firmware form source code.
>Please download the source from
>+		hg clone
>http://xenbits.xensource.com/ext/efi-vfirmware.hg
>+		Use the Guide of the source to build open Guest
>Firmware.
The Guide is not include in this README,
so we may make a link to the Guide in wiki.
Or we may add a link to binary release of GFW.

Best Regards,

Akio Takebe

