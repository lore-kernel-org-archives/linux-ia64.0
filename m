From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 15 Mar 2016 22:13:31 +0000
Subject: Re: [PATCH] ia64: define ioremap_uc()
Message-Id: <20160315151331.5359bfcece84a4889ecfd2d7@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <201603062005.lhOBibd1%fengguang.wu@intel.com>
	<1457382894-13553-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1457382894-13553-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, mingo@kernel.org, bp@suse.de

On Mon,  7 Mar 2016 12:34:54 -0800 "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:

> All architectures now need ioremap_uc(), ia64 seems defines
> this already through its ioremap_nocache() and it already
> ensures it *only* uses UC.
> 
> Reported-by: 0 day bot
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> ---
> 
> Note, this is actually needed since v4.3 to complete an allyesconfig
> compile on ia64, there were others archs that needed this, and this
> one just seems to have fallen through the cracks.

So a cc:stable was needed.  I've added that to my copy of the patch. 
Tony ack?
