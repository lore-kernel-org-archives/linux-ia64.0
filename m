From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Oct 2004 08:58:59 +0000
Subject: Re: [PATCH] IA64: fix unprotected access of user memory in system call emulation layer
Message-Id: <16739.46035.897839.631002@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410061050.15337.cborntra@de.ibm.com>
In-Reply-To: <200410061050.15337.cborntra@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christian =?iso-8859-1?q?Borntr=E4ger?= <cborntra@de.ibm.com>
Cc: davidm@hpl.hp.com, linux-ia64@vger.kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org

>>>>> On Wed, 6 Oct 2004 10:50:15 +0200, Christian Borntr=E4ger <cborntra@d=
e.ibm.com> said:

  Christian> Hello, the current IA64/IA32 emulation layer might oops
  Christian> due to an unprotected access of user memory.  This patch
  Christian> fixes the problem by using the data from __get_user.
  Christian> Please Apply

Already fixed (since yesterday!):

 http://lia64.bkbits.net:8080/linux-ia64-release-2.6.9/cset@416225cfObm2S3b=
JVFhQdG2mIL71rw

Thanks,

	--david
