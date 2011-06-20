From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 20 Jun 2011 00:42:52 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of
Message-Id: <20110620004252.GE19693@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu> <4DFE7FF9.9070406@gmail.com>
In-Reply-To: <4DFE7FF9.9070406@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Mon, Jun 20, 2011 at 09:02:17AM +1000, Ryan Mallon wrote:
> There are drivers where this makes sense. For example an FPGA device  
> with a proprietary register layout on the memory bus can be done this  
> way. The FPGA can simply be mapped in user-space via /dev/mem and  
> handled there. If the device requires no access other than memory bus  
> reads and writes then writing a custom char device driver just to get an  
> mmap function seems a bit overkill.

Calling a 30 line device driver "overkill" might in itself be overkill?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
