From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 14 Mar 2005 18:48:46 +0000
Subject: Re: How should I proceed with page table caches?
Message-Id: <16949.56462.387478.1594@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050314172733.GA11272@lnx-holt.americas.sgi.com>
In-Reply-To: <20050314172733.GA11272@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 14 Mar 2005 11:27:33 -0600, Robin Holt <holt@sgi.com> said:

  Robin> Tony and David, Is there any chance I can do another push of
  Robin> the page table cache stuff with the last bits of cleanup and
  Robin> those getting in without addressing the removal of the
  Robin> cpu_idle() call?  Neither solution I was given last week
  Robin> seems particularly well fitted to the problem at hand.  I
  Robin> would like to get this in so I can continue working on the
  Robin> 4-level page table directory I am really trying to address.

From memory, the last version I saw looked pretty decent to me.

I agree with Ken's concerns, but given that we have historically done
page-table cache shrinking from cpu_idle(), your patch doesn't worsen
the situation (unless I'm missing something), so I think that concern
could be addressed separately.

	--david
