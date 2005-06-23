From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Thu, 23 Jun 2005 23:43:51 +0000
Subject: Re: [ia64][patch] Refuse inserting kprobe on slot 1
Message-Id: <20050623164351.A26121@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506230232.j5N2WgwS018522@linux.jf.intel.com>
In-Reply-To: <200506230232.j5N2WgwS018522@linux.jf.intel.com>; from rusty.lynch@intel.com on Wed, Jun 22, 2005 at 07:32:42PM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Lynch <rusty.lynch@intel.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Jun 22, 2005 at 07:32:42PM -0700, Rusty Lynch wrote:
> 
>    +
>    +       if (slot = 1) {
Rusty, this is wrong. You should fail only
	if (slot = 1) && (bundle_encoding[template][1] != L) {
This is because for MLX template we will actually be patching
the instruction on slot = 2 and not on slot 1.
>    +               printk(KERN_WARNING "Inserting kprobes on slot #1 "
>    +                      "is not supported\n");
>    +               return -EINVAL;
>    +       }
>    +
>            return 0;
>     }
> 

-Anil
