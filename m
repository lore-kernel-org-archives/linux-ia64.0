From: Matthew Wilcox <willy@debian.org>
Date: Tue, 23 Jul 2002 01:21:39 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905808@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 22, 2002 at 06:10:11PM -0700, David Mosberger wrote:
> Argh, I'm sorry about that.  This wasn't my intention.  I think I
> misread e100 and e1000 and picked that one up by accident.
> 
> I'll fix that and update the 2.4.18 patch shortly.  I would like to
> have a final 2.4.18 patch without silly issues like these.  (Assuming
> 2.4.19 shows up relatively soon).

well, the eepro100 patch does fix a real problem on those cards.  is there
a real problem with increasing the default swiotlb size?

-- 
Revolutions do not require corporate support.

