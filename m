From: Grant Grundler <grundler@cup.hp.com>
Date: Tue, 23 Jul 2002 01:35:33 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905810@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kimio Suganuma wrote:
> I found eepro100 driver was trying to get swiotlb of
> (0x610 bytes * 1024 = 0x184000) at booting, and this caused
> swiotlb shortage.
> 
> I guess the problem might be caused by this modification;
> 
> > - Include eepro1000 and Tigon3 support (various, plus bug fixes by
> >   Grant Grundler for these and other gigE cards)

later versions of the eepro100 patch used RX_RING_SIZE of 64.
So I'll guess it's safe to use a smaller value than 1024.

grant

