From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 May 2003 08:08:19 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705755@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 May 2003 09:38:05 +0200, Bruno Vidal <bruno_vidal@hp.com> said:

  Bruno> There is no other way to access EFI or firmware ?

The EFI standard certainly won't help you here.  Whether or not
vendors have their own backdoors to a low-level disk driver, I don't
know.

  Bruno> Or reset back EFI to have access to BLOCK IO interface ?

You can warm-boot via EFI.  But I'm not sure there is any guarantee
that all kernel memory will be preserved.

	--david

