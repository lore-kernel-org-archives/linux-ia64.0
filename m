From: Keith Owens <kaos@sgi.com>
Date: Tue, 23 Nov 2004 02:36:38 +0000
Subject: Re: smp_call_function/flush_tlb_all hang on large memory system
Message-Id: <12621.1101177398@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Tue, 23 Nov 2004 07:41:07 +0530."
             <267988DEACEC5A4D86D5FCD780313FBB2BFBB6@exch-03.noida.hcltech.com> 
References: <20041122121415.GA13845@lnx-holt.americas.sgi.com>
In-Reply-To: <20041122121415.GA13845@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Deepak Kumar Gupta, Noida" <dkumar@hcltech.com>
Cc: 'Robin Holt ' <holt@sgi.com>, "''lilbilchow@yahoo.com' '" <lilbilchow@yahoo.com>, "''ananth@sgi.com' '" <ananth@sgi.com>, "''linux-kernel@vger.kernel.org' '" <linux-kernel@vger.kernel.org>, "''linux-ia64@vger.kernel.org' '" <linux-ia64@vger.kernel.org>

It has always been an error to call smp_call_function() with interrupts
disabled.  Recent 2.6 kernels check for this and issue a warning.  The
problem is not smp_call_function() or flush_tlb_all(), it is the code
that called them with interrupts disabled.  Find the calling code and
fix it to not disable interrupts.

