From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 13 Nov 2003 17:41:41 +0000
Subject: Re: problem in booting HP zx6000 with stock kernel 2.5.75
Message-Id: <marc-linux-ia64-106874596811058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106840426422921@msgid-missing>
In-Reply-To: <marc-linux-ia64-106840426422921@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 13, 2003 at 02:51:43PM +0000, Matthew Wilcox wrote:
> Jesse and I discussed this yesterday.  To take advantage of the
> new multiple-defconfigs scheme in 2.6, what we need to do is:
> 
>  - Create files called arch/ia64/configs/*_defconfig
>  - To use them, type "make zx1_defconfig" (for example).
>  - Keep them up to date ...
> 
> There's a bikeshed question about which configs to support.  I think
> the rule is pretty simple -- if someone's willing to step up and maintain
> the config for a platform, let's put it in.
> 
> I'd suggest we want to have defconfig as generic, then add configs/
> 
>  - zx1_defconfig
>  - sn2_defconfig
>  - dig_defconfig (should work for bigsur, lion, tiger boxes)
>  - sim_defconfig
> 
> I don't mind maintaining the zx1_defconfig if nobody else wants to.

Sounds like a plan to me.  I'll take care of sn2_defconfig.  Seems like
these files should go in shortly after 2.6.0 releases so that people
have something usable for the stable kernel.

Jesse
