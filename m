From: Piet/Pete Delaney <piet@sgi.com>
Date: Fri, 22 Mar 2002 00:55:58 +0000
Subject: Re: [Linux-ia64] Re: Running ia64 2.4.17 kernel on RedHat 7.2 and problems with LoadModule: "scanpci
Message-Id: <marc-linux-ia64-105590701905321@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905319@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905319@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 22, 2002 at 11:27:35AM +1100, Keith Owens wrote:
> On Thu, 21 Mar 2002 15:42:55 -0800, 
> Piet/Pete Delaney <piet@sgi.com> wrote:
> >On Fri, Mar 22, 2002 at 08:30:54AM +1100, Keith Owens wrote:
> >> On Wed, 20 Mar 2002 22:51:32 -0800, 
> >> Piet/Pete Delaney <piet@sgi.com> wrote:
> >> >How do I build: 
> >> >
> >> >	/boot/module-info-${KERNELRELEASE}
> >> >	/boot/kernel.h-${KERNELRELEASE}
> >> 
> >> Redhat special files, not part of the kernel build.
> >
> >Any idea what they do?  Perhaps it's involved with my X11R6 problem below...
> 
> RH use module-info to map devices to kernel.

Like frame buffers?

.
.
.

> >What does "binary only module at boot time" mean?
> 
> Binary only modules (BOM) either have no source or the source is not
> GPL.  Linus has "allowed" binary only kernel code as modules.  Binary
> only code cannot be linked into the kernel if you distribute the
> kernel.  What you do in the privacy of your own machine is up to you,
> the GPL only bites if you distribute your kernel.

What about modules that aren't distributed with the kernel but 
are released as objects (perhaps src) to be linked into the kernel 
by the customer. For example, something like kdb. Your saying a company
that distributes kdb like objects that the a sustomer links into the
kernel must release the src of the objects under the GPL license.

So for you to release something like kdb sourceless you would have to
link it into the kernel as a module and make it useless for early startup.


> If your kernel requires a binary only driver in order to boot then that
> driver must be a module.
right.

>                         To load a driver at boot time, you have to
> use initrd.  My attitude is that unless you absolutely need initrd,
> don't use it.

Yep, I like just linking the stuff in and keeping things as simple as possible.


-piet

