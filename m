From: Dave Jones <davej@redhat.com>
Date: Wed, 06 Apr 2005 00:48:07 +0000
Subject: Re: [03/08] fix ia64 syscall auditing
Message-Id: <20050406004807.GB13518@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405164539.GA17299@kroah.com> <20050405164647.GD17299@kroah.com> <16978.62622.80542.462568@napali.hpl.hp.com> <1112734158.468.0.camel@localhost.localdomain> <20050405234602.GC4800@mythryan2.michonline.com> <1112745904.412.4.camel@localhost.localdomain>
In-Reply-To: <1112745904.412.4.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@suse.de>
Cc: Ryan Anderson <ryan@michonline.com>, davidm@hpl.hp.com, linux-kernel@vger.kernel.org, stable@kernel.org, amy.griffis@hp.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dwmw2@infradead.org

On Tue, Apr 05, 2005 at 05:05:04PM -0700, Greg KH wrote:
 > On Tue, 2005-04-05 at 19:46 -0400, Ryan Anderson wrote:
 > > highlight WhitespaceEOL ctermbg=red guibg=red
 > > match WhitespaceEOL /\s\+$/
 > 
 > Very nice, thanks a lot for that.
 
let c_space_errors=1  also works great.

		Dave

