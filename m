From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 18 Jan 2001 18:14:41 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_PAGE_SIZE
Message-Id: <marc-linux-ia64-105590693005080@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005077@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005077@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 18 Jan 2001 09:55:32 -0800, "Broadfoot, KenX" <kenx.broadfoot@intel.com> said:

  Ken> Anyone in the know,

  Ken> I am using a 16KB page size for my Lion systems.

  Ken> Under the help section of make menuconfig is says:

  Ken> 4KB best for ia32

  Ken> 8KB best for ia64

  Ken> 16KB best for ia64

  Ken> 64KB Not for Itanium


  Ken> I just want to know what is the gain or loss if I used 8KB
  Ken> instead of 16KB page size.

Based on recent measurements by Don and myself, I'd recommend 16KB.
For example, local kernel compiles go noticably faster that way.

	--david

