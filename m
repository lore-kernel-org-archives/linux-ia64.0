From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 07 Dec 2002 07:18:34 +0000
Subject: Re: [Linux-ia64] ia64 arch makefile update
Message-Id: <marc-linux-ia64-105590709805514@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805512@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 06, 2002 at 11:41:41PM +0100, Sam Ravnborg wrote:
> Hi all.
> Following is an update of various ia64 specific makefiles.
> Patch is on top of linus-latest, with the 2.5.50 ia64 patch posted here applied.
> 
> Summary of changes:
> o Simplified arch/ia64/Makefile
>   - During this process the boot: target were removed
> o Moved final generation of vmlinux.gz to boot/Makefile
>   - This allowed me to use some of the kbuild infrastructure
>   - Final file "vmlinux.gz" is now saved in arch/ia64/boot in line with
>     other architectures.
> o s/$(ARCH)/ia64 - since we know that this is the architecture we use
> o Small clean up all over, e.g. removed inclusion of Rules.make
>   Also made some nicer indenting, but no functional changes.

I have been requested to enable the following scenario:
        $ make
        $ ski bootloader vmlinux

And I also have realised that
	$ make boot

is used when compiling for the simulator only.

So I will send an update during the weekend, as Real Life(tm) permits ;-)

	Sam

