From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 14 Oct 2004 08:25:45 +0000
Subject: Re: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <1097742344.318.596.camel@hades.cambridge.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com>
	 <20041007142710.A12688@infradead.org> <4165D4C9.2040804@intel.com>
	 <mailman.1097223239.25078@unix-os.sc.intel.com>
	 <41671696.1060706@intel.com>
	 <mailman.1097403036.11924@unix-os.sc.intel.com>
	 <416AF599.2060801@intel.com>
	 <1097617824.5178.20.camel@localhost.localdomain>
	 <416C5ECF.6060402@intel.com> <416DABB9.8050804@intel.com>
	 <16750.11146.297875.521746@napali.hpl.hp.com>
In-Reply-To: <16750.11146.297875.521746@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Arun Sharma <arun.sharma@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 2004-10-14 at 00:32 -0700, David Mosberger wrote:
>   Arun> Attached is the promised patch. It addresses Christoph's
>   Arun> comments and fixes the bug Tony found as well.
> 
> I like it.  Once it's in (surely it will go in, no? ;-),

It certainly looks saner, yes. If this is the way we're going, then the
new syscall needs to be added on all other architectures, and I'd
suggest that we should see a real open-source user of it too before it's
merged. Does anyone have the qemu patches?

-- 
dwmw2

