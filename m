From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 14 Mar 2005 19:04:40 +0000
Subject: RE: How should I proceed with page table caches?
Message-Id: <200503141904.j2EJ4fg20199@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050314172733.GA11272@lnx-holt.americas.sgi.com>
In-Reply-To: <20050314172733.GA11272@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Monday, March 14, 2005 10:49 AM
> >>>>> On Mon, 14 Mar 2005 11:27:33 -0600, Robin Holt <holt@sgi.com> said:
>
>   Robin> Tony and David, Is there any chance I can do another push of
>   Robin> the page table cache stuff with the last bits of cleanup and
>   Robin> those getting in without addressing the removal of the
>   Robin> cpu_idle() call?  Neither solution I was given last week
>   Robin> seems particularly well fitted to the problem at hand.  I
>   Robin> would like to get this in so I can continue working on the
>   Robin> 4-level page table directory I am really trying to address.
>
> From memory, the last version I saw looked pretty decent to me.
>
> I agree with Ken's concerns, but given that we have historically done
> page-table cache shrinking from cpu_idle(), your patch doesn't worsen
> the situation (unless I'm missing something), so I think that concern
> could be addressed separately.


I plan to look at set_shrinker API.  But please don't make that as a gating
factor for Robin's patch since I'm not sure when I will be able to get to it
or whether set_shrinker can actually solve the problem (it appears that it
has all the necessary infrastructure).

- Ken


