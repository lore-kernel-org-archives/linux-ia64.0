From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 03 Aug 2004 21:26:15 +0000
Subject: RE: Multiple Processors on OS_MCA
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01C622E4@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> That wasn't intended to be a final solution ... just a temporary fix
>> to make sure that two processors couldn't enter the kernel at the
>> same time (which would lead to chaos in the current implementation
>> because we only have one block of memory declared to save registers,
>> use a stack etc.).
>
>Is there a plan for the next step towards the final solution?
>
>For example, would it make sense to have per CPU register & stack
>save areas (etc) to handle multiple OS_MCAs concurrently?

Zoltan posted a patch to do this ... but it looked like a huge
re-write in one big patch, and I didn't have time to look at it
then (and still don't now).  But if you wanted to dig it up, update
it and break it into bite-sized pieces ...

-Tony
