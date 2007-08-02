From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 02 Aug 2007 22:32:22 +0000
Subject: Re: ia64 mmu_gather question
Message-Id: <1186093942.5495.634.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186026055.5495.585.camel@localhost.localdomain>
In-Reply-To: <1186026055.5495.585.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2007-08-02 at 16:07 -0600, David Mosberger-Tang wrote:
> Do keep in mind that there is a hardware walker, too! ;-)

Yup, I know. Your TLB miss rate gets lower as you fault in the page
table pages, though it's still higher than a full tree walker. How big
is the TLB btw ?

Ben.


