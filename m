From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 12 Apr 2004 22:59:50 +0000
Subject: RE: newbie question regarding alloc instruction
Message-Id: <200404122259.i3CMxoF11225@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAY14-F14u04koK5uA700042e41@hotmail.com>
In-Reply-To: <BAY14-F14u04koK5uA700042e41@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>> Raj Patil wrote on Monday, April 12, 2004 1:03 PM
>
> I have a basic question about alloc instruction. I apologise if it  is too
> basic. BUt, I could not find the info in the docs I looked at...


Did you look at ia64 software developer's manual, volume 3, section 2.2?


> Are there any restrictions in using alloc instruction more than once in a
> function? (I see that some of the kernel functions do use more than once)
> If not, do I need to worry about setting/unsetting the CFM etc or will it
> be taken care by setting/resetting ar.pfs in the block.  (According to one
> of the manuals CFM can not bet set manually.)

There is no restriction on how many time alloc can be called, br.ret restores
cfm from ar.pfs.  So make sure the original pfs value is in ar.pfs register
when br.ret executes.



