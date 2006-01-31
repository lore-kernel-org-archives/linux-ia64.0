From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 19:59:54 +0000
Subject: RE: [patch 1/6] align kenrel rbs on 128 byte
Message-Id: <200601312000.k0VK02g04589@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
In-Reply-To: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Richard Harke wrote on Tuesday, January 31, 2006 11:59 AM
> > Yeah, if nobody cares about UP performance. SMP_CACHE_BYTES is 8 bytes
> > on UP kernel (though it doesn't seem that anyone cares about UP).  I
> 
> Well, I care about UP. But HP, Intel and SGI have made it pretty clear
> they don't care about UP (or the customers that have UP machines)

I heard you.  L1_CACHE_BYTES it is, so everyone can be benefited from
the change: merced processor, UP, SMP you name it.

- Ken

