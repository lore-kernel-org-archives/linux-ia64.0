From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Dec 2002 06:43:21 +0000
Subject: Re: [Linux-ia64] ia64 arch makefile update
Message-Id: <marc-linux-ia64-105590709805533@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805512@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 7 Dec 2002 23:01:45 +0100, Sam Ravnborg <sam@ravnborg.org> said:

  Sam> Second try ready.  Other architectures does not practice this,
  Sam> but I added a rule to copy vmlinux.gz + bootloader to root of
  Sam> kernel-tree.

I applied this patch now.  I changed the "copy to root" to "link to
root" and had to apply the changes to arch/ia64/Makefile manually due
to a conflict, but hope that I got everything.

Thanks for the good work.

	--david

