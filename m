From: Andi Kleen <ak@suse.de>
Date: Wed, 24 Nov 2004 10:45:14 +0000
Subject: Re: [PATCH 1/2] setup_arg_pages can insert overlapping vma
Message-Id: <20041124104514.GD10495@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <894E37DECA393E4D9374E0ACBBE7427013C9AB@pdsmsx402.ccr.corp.intel.com> <20041123172309.60d9e9c1.akpm@osdl.org>
In-Reply-To: <20041123172309.60d9e9c1.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Zou, Nanhai" <nanhai.zou@intel.com>, hugh@veritas.com, chrisw@osdl.org, torvalds@osdl.org, tony.luck@intel.com, schwidefsky@de.ibm.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Nov 23, 2004 at 05:23:09PM -0800, Andrew Morton wrote:
> "Zou, Nanhai" <nanhai.zou@intel.com> wrote:
> >
> > I think ia64 ia32
> > subsystem is not vulnerable to this kind of overlapping vm problem,
> > because it does not support a.out binary format, 
> > X84_64 is vulnerable to this. 
> 
> Martin, Andi and Tony: could we please get a 2.6.10 ack on this from you?

Looks good to me.

-Andi
