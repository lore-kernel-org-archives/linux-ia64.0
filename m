From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 13 Dec 2005 14:06:48 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <439ED578.8000107@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab wrote:
> "Luck, Tony" <tony.luck@intel.com> writes:
> 
> 
>>That looks like a plausible direction to investigate.  Does anyone know
>>whether any other architectures have a similar problem that can be solved
>>in this way?  Or is ia64 the only one with a "generic" kernel that has to
>>work on such a diverse spread of machines?
> 
> 
> PPC has CONFIG_PPC_MULTIPLATFORM, and use ppc_md much like ia64 uses
> ia64_mv.
> 

Andreas -- I just recieved the following from a PPC engineer at IBM:

"I don't think it is possible to build a ppc kernel with just
CONFIG_PPC_MULTIPLATFORM set. You'll need to "choose" another compile
option such as "cell" or "iseries" or "pseries" or somesuch (from
arch/powerpc/platforms/). Check arch/powerpc/configs for the relevant
defconfigs."

... so it looks like this is currently limited to ia64 ...

P.

> Andreas.
> 

