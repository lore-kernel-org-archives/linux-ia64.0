From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 07 Jan 2011 16:56:32 +0000
Subject: Re: Very large memory configurations:   > 16 TB
Message-Id: <20110107165632.GA7088@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110106170942.GA8253@sgi.com>
 <20110107125135.GD20761@elte.hu>
 <alpine.DEB.2.00.1101071027040.3014@router.home>
In-Reply-To: <alpine.DEB.2.00.1101071027040.3014@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux.com>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org


* Christoph Lameter <cl@linux.com> wrote:

> Andi put a description of the memory layout in
> Documentation/x86/x86_64/mm.txt. Seems to indicate that 64 TB was
> considered as a maximum when the memory layout for x86_64 was set up:

Yes, that document was rather incomplete and does not really answer Jack's 
questions, that's why i sent this more complete description originally:

  http://lkml.indiana.edu/hypermail/linux/kernel/0812.2/00292.html

a few years ago, answering a similar question.

Thanks,

	Ingo
