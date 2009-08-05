From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 05 Aug 2009 13:33:57 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m1eirqtmey.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
In-Reply-To: <20090805112123.6552.73574.sendpatchset@localhost.localdomain> (Amerigo Wang's message of "Wed\, 5 Aug 2009 07\:19\:02 -0400")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Amerigo Wang <amwang@redhat.com> writes:

> This series of patch implements automatically reserved memory for crashkernel,
> by introducing a new boot option "crashkernel=auto". This idea is from Neil.
>
> In case of breaking user-space applications, it modifies this boot option after
> it decides how much memory should be reserved.
>
> On different arch, the threshold and reserved memory size is different. Please
> refer patch 7/7 which contains an update for the documentation.
>
> Note: This patchset was only tested on x86_64 with differernt memory sizes.

This seems like a silly hard code. Especially for a feature distros don't
care enough about to implement a working initrd for.

Has anyone bothered to justify those large amounts of memory?
Where does the 128M go?

Please pardon me for being a cynic but I don't see the command line option
being the bottleneck for real users to make this work.

Eric
