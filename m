From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 17 Nov 2004 22:37:31 +0000
Subject: Re: [Fastboot] [PATCH] Fix for kexec reboot failing after multiple
Message-Id: <419BD2AB.1050203@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Khalid Aziz wrote:
> kexec patch I had sent out earlier has bug where it appends
> "kexec_reboot" to kernel parameters blindly. After several kexec reboots
> from kexec'd kernel, kernel parameters line becomes too long and kernel
> fails to boot. Attached patch  will cure this. Patch

This particular problem is not ia64-specific.  I have seen it on ia32.
Did you fix it in a generic manner (for any $arch) ?

> kexec-ia64-reboot.diff can be applied on top of the previous patch I had
> sent. Patch 2.6.8.1-kexec3-ia64-2.diff includes this fix and is
> repalcement for my previous patch. 
> 
> My current kexec patches for ia64 can also be found at
> <http://free.linux.hp.com/~khalid/kexec-ia64/>.

Thanks,
-- 
~Randy
