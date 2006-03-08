From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 08 Mar 2006 21:22:21 +0000
Subject: Re: 2.6.16-rc5 perfmon2 new code base + libpfm with Montecito support
Message-Id: <20060308212221.GB14435@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308155311.GD13168@frankl.hpl.hp.com> <440F4130.5040703@redhat.com>
In-Reply-To: <440F4130.5040703@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@redhat.com>
Cc: linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Will,

On Wed, Mar 08, 2006 at 03:40:16PM -0500, William Cohen wrote:
> >
> >I have released another version of the perfmon new base package.
> >This release is relative to 2.6.16-rc5
> 
> Hello Stephane,
> 
> Is there any thoughts on how perfmon2 is going to work with xen enabled 
> kernels or processors that support virtualization?
> 

AFAIK, there is currently no Xen support for PMU on any platforms. By "support"
I mean suport for guests using the PMU. As such, I do not think this works.
I am planning on looking at this next because this is becoming a pressing matter
and not just on IA-64.

My first goal is to ensure that a guest using perfmon2 works once it is virtualized.
That implies that the Xen VMM does save/restore PMU state on guest switch. That's a bare
minimum.

As for HW virutlization support, I think it helps a little bit but there still needs to
be some additional code in the VMM to make this work correctly. This is also something
I want to look at.

-- 
-Stephane
