From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Nov 2002 18:39:28 +0000
Subject: Re: [Linux-ia64] EFI/SAL question
Message-Id: <marc-linux-ia64-105590709805432@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805425@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805425@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Nov 2002 12:30:34 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Hi, does EFI (runtime services) or SAL calls use the
  Christian> global pointer? If yes, how must gp initialized before
  Christian> doing the call (from assembly)?

Yes, both use GP.  For SAL, the GP is provided via the
SAL_DESC_ENTRY_POINT descriptor (page 419 in the ia64 linux kernel
book).  For EFI, the runtime services routines are given as normal
function pointers (so they contain both code entry point and gp).

	--david

