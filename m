From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 15 Mar 2004 06:48:52 +0000
Subject: Re: [oatch] 2.6.4 Decode salinfo oemdata via prom
Message-Id: <20040315064852.A15330@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <2724.1079310544@kao2.melbourne.sgi.com>
In-Reply-To: <2724.1079310544@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 15, 2004 at 11:29:04AM +1100, Keith Owens wrote:
> + * Further, this software is distributed without any warranty that it is 
> + * free of the rightful claim of any third person regarding infringement 
> + * or the like.  Any license provided herein, whether implied or 
> + * otherwise, applies only to this software file.  Patent licenses, if 
> + * any, provided herein do not apply to combinations of this program with 
> + * other software, or any other product whatsoever.

Don't use that boilerplate.  The SGI code has recently been changed to avoid
it because it imposes further restrictions that the GPL doesn't allow.

