From: Matthew Wilcox <willy@debian.org>
Date: Thu, 13 Nov 2003 14:51:43 +0000
Subject: Re: problem in booting HP zx6000 with stock kernel 2.5.75
Message-Id: <marc-linux-ia64-106873807631278@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106840426422921@msgid-missing>
In-Reply-To: <marc-linux-ia64-106840426422921@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 12, 2003 at 08:51:29AM -0800, Jesse Barnes wrote:
> Hi Ian, here's a patch that adds config files for sn2 and generic
> builds.  I've been thinking that maybe arch/ia64/defconfig should be a
> generic kernel though, one that can run on dig (tiger and NEC
> preferably), zx1, and sn2 boxes, and that we have a couple of other
> configs in arch/ia64 somewhere for specific machines.
> diff -Nru a/arch/ia64/configs/generic b/arch/ia64/configs/generic
> diff -Nru a/arch/ia64/configs/sn2 b/arch/ia64/configs/sn2

Jesse and I discussed this yesterday.  To take advantage of the
new multiple-defconfigs scheme in 2.6, what we need to do is:

 - Create files called arch/ia64/configs/*_defconfig
 - To use them, type "make zx1_defconfig" (for example).
 - Keep them up to date ...

There's a bikeshed question about which configs to support.  I think
the rule is pretty simple -- if someone's willing to step up and maintain
the config for a platform, let's put it in.

I'd suggest we want to have defconfig as generic, then add configs/

 - zx1_defconfig
 - sn2_defconfig
 - dig_defconfig (should work for bigsur, lion, tiger boxes)
 - sim_defconfig

I don't mind maintaining the zx1_defconfig if nobody else wants to.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
