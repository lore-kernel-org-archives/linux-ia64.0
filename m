From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 07 Nov 2002 16:38:08 +0000
Subject: Re: [Linux-ia64] [PATCH] Performance Patch for TLB misses
Message-Id: <marc-linux-ia64-105590709805351@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805350@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805350@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 07 Nov 2002 15:00:27 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> - let the processor also check for privilege level
  Christian> because it's very very rare

I didn't look at the patch too closely but this change looks wrong.
It would let user level insert arbitrary identity-mapped TLB
translations, which is not safe because it can trigger memory
attribute aliasing.

	--david

