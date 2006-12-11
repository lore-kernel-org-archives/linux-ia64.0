From: Fenghua Yu <fenghua.yu@intel.com>
Date: Mon, 11 Dec 2006 21:25:25 +0000
Subject: Re: [PATCH 2/5] Itanium MC Error Injection Tool: Doc and sample application
Message-Id: <20061211212525.GA23260@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161422.A1100@unix-os.sc.intel.com>
In-Reply-To: <20061208161422.A1100@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 11, 2006 at 01:36:04PM -0800, Luck, Tony wrote:
> > > Is it better to move above definitions to file include/asm-ia64/pal.h?
> > > 
> definitely split out these structure definitions into an err_inject.h
> to make it easy for you all to write fabulous injection tools.
> 
The sample application only defines part of structures and implements part of the features. To fit into the err_inject.txt, it's simplified to only one .c file. More fabulous tools are recommended to be developed in the community on the top of the current work.

Thanks.

-Fenghua
