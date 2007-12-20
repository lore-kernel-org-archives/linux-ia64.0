From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 20 Dec 2007 17:03:25 +0000
Subject: Re: [PATCH] Export three symbols for kvm use.
Message-Id: <20071220170324.GA29209@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCB139E3@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCB139E3@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

On Thu, Dec 20, 2007 at 01:57:01PM +0800, Zhang, Xiantao wrote:
> Hi Tony,
> 	In order to build kvm source successfully, we need to export
> three symbols for kvm use. Please review. Maybe Avi can check-in to
> kvm.git upstream first. 
> 
> Thanks
> Xiantao 
> From: Zhang Xiantao <xiantao.zhang@intel.com>
> Date: Thu, 20 Dec 2007 09:37:41 +0800
> Subject: [PATCH] ia64: Export three symbols for module use
> 
> Since kvm/module needs to use some unexported functions in kernel,
> so export them with this patch.

Please submit this together with the actual kvm code as we don't export
symbols for out of tree usage, thanks.

