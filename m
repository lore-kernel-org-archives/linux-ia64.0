From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 13 Jan 2004 16:08:43 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <20040113160843.GA16138@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry about that.  I guess that's what happens when I send you a non-p1
patch :(

On Mon, Jan 12, 2004 at 05:36:46PM -0800, David Mosberger wrote:
> >>>>> On Mon, 12 Jan 2004 16:59:53 -0800 (PST), Linus Torvalds <torvalds@osdl.org> said:
> 
>   Linus> On Mon, 12 Jan 2004, David Mosberger wrote:
>   >> 
>   >> Note: this part:
>   >> 
>   >> ia64/configs/generic_defconfig      | 1045 ------------------------------------
>   >> ia64/configs/generic_defconfig      | 1045 ++++++++++++++++++++++++++++++++++++
>   >> is a no-op.
> 
>   Linus> No it isn't. After doing a pull, the
>   Linus> ia64/confis/generic_defconfig file exists (along with all the
>   Linus> bogus directories, of course).
> 
>   Linus> Not applied, please fix your tree.
> 
> Ugh, I forgot to push the fix into to bkbits.net tree.
> 
> Sorry about that.  It should be there now.
> 
> 	--david
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
