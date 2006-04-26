From: Jeff Dike <jdike@addtoit.com>
Date: Wed, 26 Apr 2006 18:42:48 +0000
Subject: Re: [PATCH 3/5] Remove redundant NULL checks before [kv]free - in  arch/
Message-Id: <20060426184248.GB9269@ccure.user-mode-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200604170328.42599.jesper.juhl@gmail.com>
In-Reply-To: <200604170328.42599.jesper.juhl@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Erich Focht <efocht@ess.nec.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, eranian@hpl.hp.com, davidm@hpl.hp.com, Ben Herrenschmidt <benh@kernel.crashing.org>, paulus@samba.org, user-mode-linux-devel@lists.sourceforge.net, Jan Engelhardt <jengelh@linux01.gwdg.de>

On Mon, Apr 17, 2006 at 03:28:42AM +0200, Jesper Juhl wrote:
> Remove redundant NULL checks before [kv]free + small CodingStyle cleanup
> for arch/
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

The UML bits are applied, thanks.

			Jeff
