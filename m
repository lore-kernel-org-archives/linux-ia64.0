From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 15 Dec 2005 20:56:30 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <43A1D87E.7060900@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:

> 
> The point is, I think it's a mistake to use ia64_platform_is()
> to decide whether to bind a driver to a device.  I think it would
> be much better to make it explicit that these are drivers, and
> they only bind to specific devices.
> 

Yes, I agree with that ...

> I do recognize that this doesn't cover all the current uses of
> ia64_platform_is(), but it covers a pretty big chunk of them.
> 

Which prolly means that I should continue with the solution that was 
previously put forward.

P.
