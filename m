From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Thu, 19 Oct 2017 14:11:24 +0000
Subject: Re: [RFC][PATCH v2 0/7] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20171019141124.GB498@tigerII.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
 <20170922053404.3zpfpwetabjut2er@santosiv.in.ibm.com>
 <20170922080023.GA599@jagdpanzerIV.localdomain>
 <3908561D78D1C84285E8C5FCA982C28F61381992@ORSMSX114.amr.corp.intel.com>
 <20170925070542.GA387@jagdpanzerIV.localdomain>
 <871smsg2fc.fsf@concordia.ellerman.id.au>
In-Reply-To: <871smsg2fc.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "Luck, Tony" <tony.luck@intel.com>, Santosh Sivaraj <santosh@fossix.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-kernel@vger.kernel

Michael,

On (09/27/17 15:01), Michael Ellerman wrote:
> Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> writes:
> 
> > On (09/22/17 16:48), Luck, Tony wrote:
> > [..]
> >> Tested patch series on ia64 successfully.
> >> 
> >> Tested-by: Tony Luck <tony.luck@intel.com>
> >
> > thanks!
> >
> >> After this goes upstream, you should submit a patch to get rid of
> >> all uses of %pF (70 instances in 35 files) and %pf (63 in 34)
> >> 
> >> Perhaps break the patch by top-level directory (e.g. get all the %pF
> >> and %pF in the 17 files under drivers/ in one patch).
> >
> > frankly, I was going to have some sort of a lazy deprecation process:
> > didn't plan to send out a patch set that would hunt down all pf/pF-s.
> > hm...
> 
> That never works though, we have lots of cruft left over from times when
> that's happened and the conversion never quite got finished.

this time around it's different, I promise! :)


well...
I guess I can send out a tree wide pf/pF removal patch set. later.
when we will see that .opd based dereference does not make anyone
unhappy.

and I think we can't remove pf/pF from the kernel completely. it
will stay in vscnprintf() for some time. old habits die hard, I suppose,
there might be people using it for debugging/etc.


> At least if you send out the patches to do the removal they might
> eventually get merged.
> 
> > speaking of upstream, any objections if this patch set will go through
> > the printk tree, in one piece?
> 
> Do you mind putting it in a topic branch (based on rc2) and then merge
> that into the printk tree? That way I can merge the topic branch iff
> there are conflicts later down the line towards 4.15.

ok, let me re-spin the series. there are some changes here
and there, so I'll drop Tested-by/Reviewed-by tags and will
ask platforms' maintainers to re-test the patch set :(

if everything goes OK, then we can ask Petr to do the topic
branch (I don't have a kernel.org account).

	-ss
