From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Jul 2001 19:22:50 +0000
Subject: RE: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
Message-Id: <marc-linux-ia64-105590693005972@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 31 Jul 2001 11:57:09 -0700, "Dong Wei" <dong_wei@hp.com> said:

  Dong> AR.k0 contains the virtual address that SAL uses for the IO
  Dong> Port Base.  The SAL spec asks the OSes not to change this
  Dong> value until the IVAs are taken over. The reason for this is
  Dong> that some implementation of SAL contains the x86 BIOS code.

Yup.  We don't violate this assumption as we switch the IVA long
before we touch AR.k0.

	--david

