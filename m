From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 28 Jan 2004 23:57:49 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <16408.19581.3185.272432@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jack" = Jack Steiner <steiner@SGI.com> writes:

Jack> On Wed, Jan 28, 2004 at 09:17:59PM +0000, Christoph Hellwig
Jack> wrote:
>> On Wed, Jan 28, 2004 at 02:59:12PM -0600, Jack Steiner wrote: >
>> +#ifdef CONFIG_NUMA > + cpus_clear(mm->cpu_vm_mask); > +#endif
>> 
>> I really hate this ifdefs all over the place.  Does this really
>> hurt that much on non-NUMA systems?  Also SN2 seems to use this
>> code always so CONFIG_NUMA looks like the wrong ifdef to me.

Jack> Are you suggesting that we remove the #ifdef OR hide the code in
Jack> a function that, depending on config options, may or may not do
Jack> anything?

Jack> The code is needed on kernels built for SN2. That includes both
Jack> CONFIG_IA64_GENERIC & CONFIG_IA64_SGI_SN2. I agree that
Jack> CONFIG_NUMA is not a great choice but nothing else seemed
Jack> appropriate.

As CONFIG_IA64_GENERIC is a superset of CONFIG_IA64_SGI_SN2
why not make CONFIG_IA64_GENERIC turn on CONFIG_IA64_SGI_SN2   and
then only test for the latter.

And yes, using a function that disappears or does nothing on platforms
for which it is inappropriate is a better approach than littering
#ifdefs though the code.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
