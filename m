From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 22 Mar 2002 00:27:35 +0000
Subject: [Linux-ia64] Re: Running ia64 2.4.17 kernel on RedHat 7.2 and problems with LoadModule: "scanpci" wh
Message-Id: <marc-linux-ia64-105590701905319@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 21 Mar 2002 15:42:55 -0800, 
Piet/Pete Delaney <piet@sgi.com> wrote:
>On Fri, Mar 22, 2002 at 08:30:54AM +1100, Keith Owens wrote:
>> On Wed, 20 Mar 2002 22:51:32 -0800, 
>> Piet/Pete Delaney <piet@sgi.com> wrote:
>> >How do I build: 
>> >
>> >	/boot/module-info-${KERNELRELEASE}
>> >	/boot/kernel.h-${KERNELRELEASE}
>> 
>> Redhat special files, not part of the kernel build.
>
>Any idea what they do?  Perhaps it's involved with my X11R6 problem below...

RH use module-info to map devices to kernel.  kernel.h just says how
the installed kernel was compiled, almost irrelevant if you build your
own.  I doubt that either are causing your problem.

>> mkinitrd, if you really insist.  initrd is useful for distributors and
>> when you need a binary only module at boot time.  Otherwise initrd is a
>> pain in the neck, build boot drivers into the kernel instead.
>
>What does "binary only module at boot time" mean?

Binary only modules (BOM) either have no source or the source is not
GPL.  Linus has "allowed" binary only kernel code as modules.  Binary
only code cannot be linked into the kernel if you distribute the
kernel.  What you do in the privacy of your own machine is up to you,
the GPL only bites if you distribute your kernel.

If your kernel requires a binary only driver in order to boot then that
driver must be a module.  To load a driver at boot time, you have to
use initrd.  My attitude is that unless you absolutely need initrd,
don't use it.

IANAL, not speaking for anyone except myself, blah, blah, blah.

