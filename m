From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Mar 2003 17:40:55 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806061@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 Mar 2003 17:38:44 +0100, Jan Schreckenbach <Jan.Schreckenbach@sap.com> said:

  Jan> Hello, why should the page size on Itanium 2 not bigger than
  Jan> 16KB?

On 2.4, there are some interesting filesystem issues with a 64KB page
size.  Besides that, 64KB obviously leads to much higher internal
fragmentation, so I wouldn't recommend it for systems with "small"
amounts of memory (less than a couple of gigs).

On the other hand, the performance measurements I have done with 64KB
page size suggested that the page size could become the sweet-spot
much sooner than I had expected.  It wouldn't surprise me if 2-3 years
from now, we started seeing normal distributions ship with 64KB page
size by default (and of course, for special environments/applications,
64KB page size makes tons of sense today already).

	--david

