From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sun, 08 Jan 2012 16:14:01 +0000
Subject: Re: [RFC PATCH v2 8/9] smp: refactor on_each_cpu to void returning
Message-Id: <20120108161401.GE21765@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1326029549-2794-1-git-send-email-gilad@benyossef.com> <1326029549-2794-9-git-send-email-gilad@benyossef.com>
In-Reply-To: <1326029549-2794-9-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Grant Likely <grant.likely@secretlab.ca>, Rob Herring <rob.herring@calxeda.com>, linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, linux-arm-kernel@lists.infradead.org

On Sun, Jan 08, 2012 at 03:32:28PM +0200, Gilad Ben-Yossef wrote:
> on_each_cpu returns the retunr value of smp_call_function
> which is hard coded to 0.
> 
> Refactor on_each_cpu to a void function and the few callers
> that check the return value to save compares and branches.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Reviewed-by: Michal Nazarewicz <mina86@mina86.com>
> CC: David Airlie <airlied@linux.ie>
> CC: dri-devel@lists.freedesktop.org
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Grant Likely <grant.likely@secretlab.ca>
> CC: Rob Herring <rob.herring@calxeda.com>
> CC: linuxppc-dev@lists.ozlabs.org
> CC: devicetree-discuss@lists.ozlabs.org
> CC: Richard Henderson <rth@twiddle.net>
> CC: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> CC: Matt Turner <mattst88@gmail.com>
> CC: linux-alpha@vger.kernel.org
> CC: Thomas Gleixner <tglx@linutronix.de>
> CC: Ingo Molnar <mingo@redhat.com>
> CC: "H. Peter Anvin" <hpa@zytor.com>
> CC: x86@kernel.org
> CC: Tony Luck <tony.luck@intel.com>
> CC: Fenghua Yu <fenghua.yu@intel.com>
> CC: linux-ia64@vger.kernel.org
> CC: Will Deacon <will.deacon@arm.com>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> CC: Russell King <linux@arm.linux.org.uk>

As there's only one place in the ARM code where we look at the return
value, and you've patched that away in patch 1, this looks fine.  I've
not checked for users outside of arch/arm, so:

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Thanks.
