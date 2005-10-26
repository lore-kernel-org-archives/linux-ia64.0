From: Gerald Pfeifer <gp@suse.de>
Date: Wed, 26 Oct 2005 18:28:04 +0000
Subject: Re: [PATCH] kexec on ia64
Message-Id: <Pine.LNX.4.63.0510262027110.6676@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 25 Oct 2005, Khalid Aziz wrote:
> I have ported the original patch I had done for kexec on ia64 on 2.6.8
> kernel and fixed a few bugs in the original patch. Attached is a patch
> for kernel 2.6.14-rc4. It works with normal kexec reboot on an HP
> rx2600. I am now working on adding support for crash kexec. I am also
> working on kexec on INIT which I currently have working on 2.6.10
> kernel. I am porting it to 2.6.14-rc kernel.
> 
> Attached patch needs to be applied on top of iomem and efi_memmapwalk
> patches already in ia64 test tree (these patches attached as well for
> those who may need them). 

Cool.  Tony, what are your plans for pushing this to Linus?  Will it make 
2.6.15?

Gerald
