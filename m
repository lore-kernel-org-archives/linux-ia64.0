From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 17 Apr 2004 12:50:14 +0000
Subject: Re: Kill off hugepage_vma()
Message-Id: <20040417125014.GE743@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040416062215.GF26707@zax> <200404162214.i3GMEdF22343@unix-os.sc.intel.com>
In-Reply-To: <200404162214.i3GMEdF22343@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, Apr 16, 2004 at 03:14:39PM -0700, Chen, Kenneth W wrote:
> Minor FYI: on ia64, huge page address is in region 4.

This is an artifact of the implementation, not a hardware limitation.


-- wli
