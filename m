From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 24 Aug 2010 20:19:51 +0000
Subject: Re: [PATCH v2] guard page for stacks that grow upwards
Message-Id: <AANLkTinMbTu6H9m70sapfpGHC4secUsaUqZKkg_=CWA6@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c7413025613b269c@agluck-desktop.sc.intel.com>
In-Reply-To: <4c7413025613b269c@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org, John David Anglin <dave.anglin@nrc-cnrc.gc.ca>, Kyle McMartin <kyle@parisc-linux.org>

On Tue, Aug 24, 2010 at 11:44 AM, Luck, Tony <tony.luck@intel.com> wrote:
>
> Built, booted & tested on ia64
> Built for x86_64 (but not booted or tested)
> pa-risc - untested

Ok, applied. I do think we could do the "VM_GROWSDOWN = 0" trick for
PA-RISC  (so that the code for the growsdown case would be compiled
away there), but that definitely needs somebody who actually cares
specifically about PA-RISC.

Adding the people who have signed off on parisc-specific patches in
recent memory to the cc. Maybe somebody could be convinced to care.

                         Linus
