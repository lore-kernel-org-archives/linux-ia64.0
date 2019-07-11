From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 11 Jul 2019 08:23:10 +0000
Subject: Re: [RFC PATCH] mm: remove quicklist page table caches
Message-Id: <alpine.DEB.2.21.1907111022400.1889@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190711030339.20892-1-npiggin@gmail.com> <0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@email.amazonses.com>
In-Reply-To: <0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christopher Lameter <cl@linux.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org

On Thu, 11 Jul 2019, Christopher Lameter wrote:

> On Thu, 11 Jul 2019, Nicholas Piggin wrote:
> 
> > Remove page table allocator "quicklists". These have been around for a
> > long time, but have not got much traction in the last decade and are
> > only used on ia64 and sh architectures.
> 
> I also think its good to remove this code. Note sure though if IA64
> may still have a need of it. But then its not clear that the IA64 arch is
> still in use. Is it still maintained?

It's kept alive
