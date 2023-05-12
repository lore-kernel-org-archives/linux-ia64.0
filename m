From: Finn Thain <fthain@linux-m68k.org>
Date: Fri, 12 May 2023 10:04:48 +0000
Subject: Re: [PATCH v6 1/6] fbdev/matrox: Remove trailing whitespaces
Message-Id: <7c2a6687-9c4e-efed-5e25-774b582e9a27@linux-m68k.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-1-tzimmermann@suse.de> <20230510110557.14343-2-tzimmermann@suse.de> <0e13efbf-9a48-6e70-fdf3-8290f28c6dc7@189.cn> <a2315b9a-0747-1f0f-1f0a-1c6773931db4@suse.de> <15fe1489-f0fa-bbf6-ec08-a270bd4f1559@gmx.de>
 <e7bd021c-1a6b-6e47-143a-36ae2fd2fe6b@suse.de>
In-Reply-To: <e7bd021c-1a6b-6e47-143a-36ae2fd2fe6b@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: Helge Deller <deller@gmx.de>, Sui Jingfeng <15330273260@189.cn>, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, arnd@arndb.de, sam@ravnborg.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On Thu, 11 May 2023, Thomas Zimmermann wrote:

> But I'd really like to see most of these drivers being moved into 
> staging and deleted soon afterwards. Users will complain about those 
> drivers that are really still required. Those might be worth to spend 
> effort on.
> 

That strategy is not going to find out what functionality is required. 
Instead it will find out which beneficiaries are capable of overcoming all 
of the hurdles to reverting deletion:

 - Find out how to report a regression correctly.
 - Gather all the necessary information.
 - Obtain buy-in from a sympathetic developer.
 - Build a patched kernel, test it and provide the results. (And possibly 
   repeat the same until neglected code becomes accepted.)
 - Wait for the relevant distro to release the relevant kernel update. 

Developers tend to overlook the burden of process because it's ostensibly 
done to raise code quality. But it seems to me that affected users are 
more likely to seek a workaround than undertake the process.

So deletion doesn't discover end-user requirements. What it does is 
advertise a vacancy for an unpaid adoptive maintainer, somehow presumed to 
be found amongst a very well remunerated and very small pool of talent.

The way I look at it, the maintainence of old code is the price of a 
so-called "right to repair". But there ain't no free lunch and if we want 
that right we should seek ways to reduce that price. For example, by 
making a larger talent pool more effective, by re-using more code and by 
improving the tooling and automation.

The code I'd delete first wouldn't be a small amount of old code in need 
of sponsorship. Or even the most buggy code. The first to go would be that 
code which will never find an actual end user because some portion of the 
code required to actually use certain platforms was never mainlined by the 
vendor -- and never will be without some push-back.
