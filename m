From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Mar 2005 20:59:15 +0000
Subject: Re: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <16946.1699.493614.729130@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 11 Mar 2005 20:25:26 +0000, Matthew Wilcox <matthew@wil.cx> said:

  Matthew> I know your patch leaaves this unchanged, but I don't think it's helpful
  Matthew> to show the 'show_stack' and 'show_regs' frames.  Can we get rid of them,
  Matthew> or is there a reason they're useful?

There were useful in the early days, when I didn't trust the unwinder... ;-)
I agree that we should drop them.  Just unwind to the interruption-frame
(pt_regs), then start printing the frames.

That'll also be more in line with the other arches.

	--david
