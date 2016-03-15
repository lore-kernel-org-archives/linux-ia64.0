From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Tue, 15 Mar 2016 22:07:06 +0000
Subject: Re: [PATCH] ia64: define ioremap_uc()
Message-Id: <20160315220706.GD1990@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <201603062005.lhOBibd1%fengguang.wu@intel.com>
 <1457382894-13553-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1457382894-13553-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, mingo@kernel.org, bp@suse.de, Andrew Morton <akpm@linux-foundation.org>

On Mon, Mar 07, 2016 at 12:34:54PM -0800, Luis R. Rodriguez wrote:
> All architectures now need ioremap_uc(), ia64 seems defines
> this already through its ioremap_nocache() and it already
> ensures it *only* uses UC.
> 
> Reported-by: 0 day bot
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>

*Poke*

  Luis
