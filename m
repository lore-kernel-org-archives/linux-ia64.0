From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Aug 2002 22:51:53 +0000
Subject: Re: [Linux-ia64] move asm-ia64/efi.h to linux/efi.h ?
Message-Id: <marc-linux-ia64-105590701905937@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905936@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905936@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 Aug 2002 17:38:11 -0500, Matt_Domsch@Dell.com said:

  Matt> David, any further thoughts on moving include/asm-ia64/efi.h
  Matt> to linux/efi.h?  Now that EFI GUID Partition Tables are part
  Matt> of the stock 2.4 and 2.5 kernel series, and can be (and will
  Matt> be!) used on x86 platforms too, several people have commented
  Matt> on l-k this week that it doesn't make sense to keep it in
  Matt> asm-ia64.  I agree.  There's also no ia64-specific code in
  Matt> there.

  Matt> I'd be happy to work up a patch to move it if there was a
  Matt> chance it would be accepted and submitted to Marcelo and
  Matt> Linus.

Oh, I'm obviously totally in favor of that, too.  It's convincing
Marcelo/Linus which may (or may not) be the hard part.  The best
argument for getting this into the linux directory would be if you can
say that x86 machine XYZ will be shipping with EFI.  But even short of
that, the fact that we already have the partition support there may be
sufficient.  So, I'd say: go for it.

	--david

