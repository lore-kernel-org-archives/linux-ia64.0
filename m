From: Grant Grundler <iod00d@hp.com>
Date: Tue, 13 Sep 2005 19:56:08 +0000
Subject: Re: [RFC] /proc/efi_memmap
Message-Id: <20050913195608.GI26350@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
In-Reply-To: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 13, 2005 at 12:30:07PM -0700, Luck, Tony wrote:
> I should dust that off and take a look at it.  /proc/iomem seems a curious
> name for a file that contains this information.

It doesn't to me. "/proc/iomem" contains host physical addresses AFAICT.
The original use might have been only for tracking MMIO, but I see no
harm in other uses.

grant
