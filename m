From: Linus Torvalds <torvalds@osdl.org>
Date: Tue, 13 Jan 2004 00:59:53 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 12 Jan 2004, David Mosberger wrote:
> 
> Note: this part:
> 
>  ia64/configs/generic_defconfig      | 1045 ------------------------------------
>  ia64/configs/generic_defconfig      | 1045 ++++++++++++++++++++++++++++++++++++
> is a no-op.

No it isn't. After doing a pull, the ia64/confis/generic_defconfig file 
exists (along with all the bogus directories, of course). 

Not applied, please fix your tree.

		Linus
