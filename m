From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Jan 2003 18:30:00 +0000
Subject: Re: [Linux-ia64] [Patch] trivial fix in linker script
Message-Id: <marc-linux-ia64-105590709805747@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 20 Jan 2003 19:16:09 -0800, "Siddha, Suresh B" <suresh.b.siddha@intel.com> said:

  Suresh> There is a chance that __start___ksymtab may not point at
  Suresh> the beginning of section __ksymtab. Appended/attached one
  Suresh> line patch fixes this problem.

It seems to me that a better solution would be to move
__start___ksymtab inside the __ksymtab section.  That should make it
always work, independent of what the real alignment of that section
is.

	--david

