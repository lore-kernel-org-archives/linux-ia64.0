From: Dan Pop <Dan.Pop@cern.ch>
Date: Tue, 19 Sep 2000 15:07:59 +0000
Subject: Re: [linux-ia64] Predication vs. Branching
Message-Id: <marc-linux-ia64-105590678205503@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205504@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205504@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 19 Sep 2000, Jonathan Case Nicklin wrote:

> This might not be the appropriate forum, but what the heck. Does anyone
> have
> a definitive answer on what happens to predicated instructions that are
> not
> executed (ie where in the pipeline are they discarded).

According to the manual, they become NOPs of the appropriate type.

Dan


